/*
    ____TRUSTED CROWDFUNDING SMART CONTRACT PROJECT____
    
    ___KEY HIHLIGHTS OF THE PROJECT___
    
    Entities:
        1) Fundraiser
        2) Crowdfunder
        3) Bank
        4) Smart Contract
    
    Transactions:
        A) Financial transactions between:
            1) Crowdfunder --> Bank.
            2) Bank --> Fundraiser.
        
        B) Donation Commintment:
            1) Crowdfunder --> Smart Contract.
            
        C) Information and Comunication:
            1) Fundraiser <--> Smart Contract.
            2) Bank <--> Smart Contract.
            3) Crowdfunder <--> Smart Contract.
            
        D) Reward Distribution:
            1) Fundraiser --> Crowdfunder.
        
    Meachanisms to Implement:
    
        NOTE: Here, [T(x)] means :
                     T  : Transaction (from above writings).
                    (x) : Alpha-numeric indication of the transaction. 
    
        1) Fundraiser Registration.
            |_> Register Fundraiser over the network [T(C1)].
            
        2) Funder Registration.
            |_> Register the Crowdfunder over the network [T(C3)].
        
        3) Fundraising Process.
            |_> a) Fundraiser submit proposal [T(C)].
                b) Verify proposal [T(C)].
                c) Upon verification, Crowdfunder publish acknowledgement [T(B)].
        
        4) Fund Donation Process.
            |_> a) Crowdfunder share details of type of transaction it wishes with Fundraiser [T(C3)].
                b) Transfer funds [T(A)].
                
        5) Fund Disbursement Process.
            |_> a) Acknowledge the funds raised [T(C1)-->T(C3)].
                b) Publish a little details of funds [T(C)].
                c) Reward the Crowdfunder [T(D)].
        
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

contract trusted_crowdfunding {
    
    
    // structure of the Fundraiser
    struct Fundraiser {
        string name;
        uint amount;
    }
    
    
    // structure of the Funder
    struct Funder {
        string name;
        address addr;
        uint amount;
    }
    
    
    // structure of nameBank
    struct nameBank {
        string funderName;
        string fundraiserName;
    }
    
    
    // list of events throughout the process
    
    event commitDonation(
        string name,
        uint amount
    );
    
    event fundraiser_to_contract(
        string name,
        uint raised_amount
    );
    
    event funder_to_contract(
        string name,
        address addr,
        uint amount
    );
    
    event contract_to_display(
        string name
    );
    
    event fundsRaised(
        string funder_name,
        string fundraiser_name,
        uint amount
    );
    
    event error(
        string message
    );
    
    
    uint nonce=9802505;
    uint mod=100;
    uint fundraiserLength=0;
    uint funderLength=0;
    
    Fundraiser[] public fundraiser;
    Funder[] public funder;
    
    mapping(uint => nameBank) funds_to_be_raised;
    
    function registerFundraiser(string memory name,uint value) public {
        fundraiser.push(Fundraiser(name,value));
        fundraiserLength++;
        emit fundraiser_to_contract(name,value);
    } 
    
    function registerfunder(string memory name,uint value) public {
        nonce++;
        address addr=address(uint160(uint(keccak256(abi.encodePacked(nonce,value))))%mod);
        funder.push(Funder(name,addr,value));
        funderLength++;
        emit funder_to_contract(name,addr,value);
    }
    
    function fundraisers_to_funder(string memory fundraiserName,string memory funderName,uint value) public {
        funds_to_be_raised[value].fundraiserName=fundraiserName;
        funds_to_be_raised[value].funderName=funderName;
    }
    
    function raiseFunds(string memory fundraiserName,string memory funderName,uint value) public {
        uint gotFundraiser=0;
        for (uint i=0;i<fundraiserLength;i++) {
            if (keccak256(bytes(fundraiser[i].name)) == keccak256(bytes(fundraiserName))) {
                gotFundraiser=i;
            }
        }
        // gotFundraiser != 0 means the fundraiser is legal and registered.
        if (gotFundraiser!=0) {
            fundraiser[gotFundraiser].amount+=value;
            for (uint i=0;i<funderLength;i++) {
                if (keccak256(bytes(funder[i].name)) == keccak256(bytes(funderName))) {
                    if (funder[i].amount>value) {
                        funder[i].amount-=value;
                        emit error("No error found. Funds transfered.");
                        emit fundsRaised(funderName,fundraiserName,value);
                        emit fundraiser_to_contract(fundraiserName,value);
                    } else {
                        emit error("Low Funds with Funder.");
                    }
                } else {
                    emit error("No such Funder found. Please contact a registered funder. Cannot transfer Funds");
                }
            }
        }
    }
    
    function fundDisbursment() public {
        for (uint i=0;i<fundraiserLength;i++) {
            if (fundraiser[i].amount==0) {
                emit contract_to_display(fundraiser[i].name);
                emit error("Sorry no funds raised.");
            } else {
                emit error("Total funds rasied:");
                emit fundraiser_to_contract(fundraiser[i].name,fundraiser[i].amount);
            }
        }
        
        for (uint i=0;i<funderLength;i++) {
            if (funder[i].amount==0) {
                emit error("Donated all of my Funds. REWARDED");
                funder[i].amount+=1000;
            }
        }
    }
}