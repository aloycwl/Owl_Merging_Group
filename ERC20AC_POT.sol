pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract ERC20AC_PotOfTea{
    event Transfer(address indexed a,address indexed b,uint value);
    event Approval(address indexed a,address indexed b,uint value);
    mapping(address=>uint)private _balances;
    mapping(address=>uint)private _access;
    uint private _totalSupply;
    modifier onlyAccess(){require(_access[msg.sender]==1);_;}
    constructor(){_access[msg.sender]=1;}
    function name()external pure returns(bytes32){return"Potty Of Tea";}
    function symbol()external pure returns(bytes32){return"POT";}
    function decimals()external pure returns(uint8){return 18;}
    function totalSupply()external view returns(uint){return _totalSupply;}
    function balanceOf(address a)external view returns(uint){return _balances[a];}
    function transfer(address a,uint b)external returns(bool){
        transferFrom(msg.sender,a,b);
        return true;
    }
    function allowance(address a,address b)external pure returns(uint){
        a;b;return 0;
    }
    function approve(address a,uint b)external pure returns(bool){
        a;b;return true;
    }
    function transferFrom(address a,address b,uint c)public returns(bool){unchecked{
        require(_balances[a]>=c&&(a==msg.sender||_access[msg.sender]==1));
        (_balances[a]-=c,_balances[b]+=c);
        emit Transfer(a,b,c);
        return true;
    }}
    function ACCESS(address a,uint b)external onlyAccess{
        if(b==0)delete _access[a];
        else _access[a]=1;
    }
    function MINT(address a,uint b)external onlyAccess{unchecked{
        b*=1e18;
        (_totalSupply+=b,_balances[a]+=b);
        emit Transfer(address(0),a,b);
    }}
    function BURN(address a,uint b)external onlyAccess{unchecked{
        b*=1e18;
        require(_balances[a]>=b);
        (_balances[a]-=b,_totalSupply-=b);
        emit Transfer(a,address(0),b);
    }}
}
