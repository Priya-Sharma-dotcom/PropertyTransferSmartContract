# PropertyTransfer Smart Contract using Escrow

A Solidity smart contract to manage property transactions with escrow and refund mechanisms.

---

## ✨ Features

* **Add Properties**: Admin (initial deployer) can register properties.
* **Buy Properties**: Buyer pays the exact Ether amount to initiate transfer.
* **Escrow System**: Ether is stored in the contract until seller confirms.
* **Ownership Transfer**: Current owner can finalize and receive payment.
* **Refund Option**: Buyer can cancel the transaction and receive refund before seller confirms.
* **Dynamic Pricing**: Price increases by 0.1 Ether after each successful transfer.

---

## 💳 How It Works

1. **Deployment**: Deploy the contract. The deployer becomes the initial contract admin.
2. **Add Property**: Admin adds a property with ID, name, location, and price.
3. **Buy Property**: Buyer sends Ether equal to the price. Contract stores it.
4. **Seller Confirms**: Property owner calls `transferOwnership()`, Ether is sent, ownership is updated.
5. **Refund**: Buyer can call `refund()` before confirmation to get their Ether back.

---

## ⚖️ Security Notes

* Uses `require()` for validations.
* Refund is protected against **reentrancy** by updating state before transferring funds.
* Only current owner can transfer ownership.

---

## 📊 Functions Overview

| Function                                 | Description                                    |
| ---------------------------------------- | ---------------------------------------------- |
| `addProperty(id, name, location, price)` | Adds a property (admin only)                   |
| `buyProperty(id)`                        | Buyer sends Ether to initiate purchase         |
| `transferOwnership(id)`                  | Seller confirms and finalizes sale             |
| `refund(id)`                             | Buyer cancels and gets refunded                |
| `getPropertyInfo(id)`                    | View full property info, including past owners |
| `getContractBalance()`                   | View total Ether in contract                   |
| `getPendingBuyer(id)`                    | View pending buyer for a property              |

---

## 📊 Data Structures

### Property

```solidity
struct Property {
    string name;
    address currentOwner;
    string location;
    uint price;
    address[] ownershipHistory;
}
```

---

## 📖 License

MIT License

---

