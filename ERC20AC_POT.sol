pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC20AC/ERC20AC.sol";
import"https://github.com/aloycwl/ERC_AC/blob/main/Util/OnlyAccess.sol";
contract ERC20AC_PotOfTea is ERC20AC,OnlyAccess{
    function name()external pure override returns(string memory){return"Pot Of Tea";}
    function symbol()external pure override returns(string memory){return"POT";}
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