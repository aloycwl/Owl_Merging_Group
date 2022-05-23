pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC20AC/ERC20AC.sol";
contract ERC20AC_PotOfTea is ERC20AC{
    mapping(address=>uint)private _access;
    modifier onlyAccess(){require(_access[msg.sender]==1);_;}
    constructor(){_access[msg.sender]=1;}
    function name()external pure override returns(string memory){return"Pot Of Tea";}
    function symbol()external pure override returns(string memory){return"POT";}
    function ACCESS(address a,uint b)external onlyAccess{
        if(b==0)delete _access[a];
        else _access[a]=1;
    }
    function MINT(address a,uint b)external onlyAccess{unchecked{
        (_totalSupply+=b,_balances[a]+=b);
        emit Transfer(address(0),a,b);
    }}
    function BURN(address a,uint b)external onlyAccess{unchecked{
        require(_balances[a]>=b);
        (_balances[a]-=b,_totalSupply-=b);
        emit Transfer(a,address(0),b);
    }}
}