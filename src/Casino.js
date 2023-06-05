import React, { useState } from 'react';
import Web3 from 'web3';

const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
const casinoAddress = '0x4c9e8125771f7f44577b53ce876615c92fe0cefa'; // Remplacer par l'adresse de votre contrat Casino
const casinoABI = [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_user1",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "_user2",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "_house",
          "type": "address"
        },
        {
          "internalType": "contract VRFCoordinatorV2Interface",
          "name": "_vrf",
          "type": "address"
        },
        {
          "internalType": "uint64",
          "name": "_subId",
          "type": "uint64"
        },
        {
          "internalType": "bytes32",
          "name": "_keyhash",
          "type": "bytes32"
        },
        {
          "internalType": "uint256",
          "name": "_fee",
          "type": "uint256"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "have",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "want",
          "type": "address"
        }
      ],
      "name": "OnlyCoordinatorCanFulfill",
      "type": "error"
    },
    {
      "inputs": [],
      "name": "bet",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "requestId",
          "type": "uint256"
        },
        {
          "internalType": "uint256[]",
          "name": "randomWords",
          "type": "uint256[]"
        }
      ],
      "name": "rawFulfillRandomWords",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ];

const casinoContract = new web3.eth.Contract(casinoABI, casinoAddress);

const Casino = () => {
    const [account, setAccount] = useState(null);

    const bet = async (amount) => {
        if (!account) return;
        
        const valueInWei = web3.utils.toWei(amount, 'ether');
        await casinoContract.methods.bet().send({ from: account, value: valueInWei });
    };

    const connectWallet = async () => {
        if (window.ethereum) {
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            setAccount(accounts[0]);
        } else {
            alert('Ethereum wallet is not available. Please install it to continue.');
        }
    };

    return (
        <div>
            <button onClick={connectWallet}>Connect Wallet</button>
            {account && (
                <div>
                    <p>Connected account: {account}</p>
                    <input type="number" id="bet-amount" placeholder="Enter bet amount in Ether" />
                    <button onClick={() => bet(document.getElementById('bet-amount').value)}>Place Bet</button>
                </div>
            )}
        </div>
    );
};

export default Casino;
