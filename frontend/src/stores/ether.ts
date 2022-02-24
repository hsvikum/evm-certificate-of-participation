import { defineStore } from "pinia";
import { ethers } from "ethers";
import contractABI from "../../artifacts/contracts/CertificateOfParticipationNFT.sol/CertificateOfParticipationNFT.json"
import contractMetaData from "../../artifacts/contractMetaData.json";

const contractAddress = contractMetaData.address;
const targetChainId = contractMetaData.chainId;

const getContractInstance = async () => {
    const signer = getSignerInstance()
    const contractInstance = new ethers.Contract(contractAddress, contractABI.abi, signer);
    return contractInstance;
}

const getSignerInstance = () => {
    const provider = getProviderInstance();
    const signer = provider.getSigner();
    return signer;
}

const getProviderInstance = () => {
    const { ethereum } = window as any;
    if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        return provider;
    } else {
        throw Error("No ethereum provider found");
    }
}

export const useEtherStore = defineStore('ether',{
  state: () => ({
    account: '',
    loading: false,
    message: '',
    minted: false,
    chainId: 0,
    contractAddress: contractAddress
  }),
  getters: {
    canInteract: (state) => (state.chainId == targetChainId && state.account !== ""),
    trimmedName: (state) => state.message.trim()
  },
  actions: {
    async hasMinted() {
        this.loading = true;
        try {
            const contractInstance = await getContractInstance();
            const mintedItemId = await contractInstance.mintedItem(this.account);
            this.minted = !mintedItemId.isZero();
        } catch (e) {
            console.error(e);
        } finally {
            this.loading = false;
        }
    },
    async mintCertificate() {
        this.loading = true;
        try {
            const contractInstance = await getContractInstance();
            if (this.trimmedName.length == 0) {
                let tnx = await contractInstance.getCertificateAnonymously();
                await tnx.wait();
            } else {
                let tnx = await contractInstance.getCertificate(this.trimmedName);
                await tnx.wait();
            }
            this.message = '';
            await this.hasMinted();
        } catch (e) {
            console.error(e);
        } finally {
            this.loading = false;
        }
    },
    async getAccount() {
        this.loading = true;
        try {
            const signer = getSignerInstance()
            this.account = await signer.getAddress();
            await this.hasMinted();
        } catch (e) {
            console.error(e);
        } finally {
            this.loading = false;
        }
    },
    async connectWallet(silent: boolean = false) {
        const { ethereum } = window as any;
        this.loading = true;
        try {
            if (!ethereum) {
                if (!silent) {
                    alert("Please install MetaMask");
                }
                return;
            }
            const accounts = await ethereum.request({ method: "eth_requestAccounts" });
            ethereum.on('chainChanged', () => {
                window.location.reload();
            });
            const { chainId } = await await getProviderInstance().getNetwork();
            this.chainId = chainId;
            if (chainId != targetChainId) {
                await ethereum.request({
                    method: "wallet_switchEthereumChain",
                    params: [{ chainId: ethers.utils.hexStripZeros(ethers.utils.hexlify(targetChainId)) }]
                });
            } else {
                if (accounts.length) {
                    await this.getAccount();
                }
            }
        } catch (e) {
            console.error(e);
        } finally {
            this.loading = false;
        }
    },
    async setupNotifications(toast: any) {
        const contractInstance = await getContractInstance();
        contractInstance.on("Transfer", (from, to) => {
            if (from == "0x0000000000000000000000000000000000000000") {
                toast.success(`${to} minted the certificate`)
            }
        }); 
    }
}
});
