pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC721AC/ERC721AC.sol";
interface IPOT{function BURN(address,uint)external;}
contract ERC721AC_TheWoobeingClub is ERC721AC{
    uint public count;
    address private ipot;
    mapping(uint=>GEN)public gen;
    mapping(uint=>OWL)private owl;
    mapping(address=>uint[])private tokens;
    struct OWL{address owner;uint parent1;uint parent2;uint time;uint gen;uint sex;string cid;}
    struct GEN{uint maxCount;uint currentCount;}
    constructor(address a){
        (ipot,_owner,gen[1].maxCount,gen[2].maxCount)=(a,msg.sender,168,1680);//TESTING VARIABLES
    }
    function balanceOf(address a)external view override returns(uint){return tokens[a].length;}
    function ownerOf(uint a)public view override returns(address){return owl[a].owner;}
    function name()external pure override returns(string memory){return"The Woobeing Club";}
    function symbol()external pure override returns(string memory){return"TWC";}
    function setCID(uint a,string memory b)external{require(_owner==msg.sender);owl[a].cid=b;}
    function GENPREP(uint a, uint b)external{require(_owner==msg.sender);gen[a].maxCount=b;}
    function transferFrom(address a,address b,uint c)public override{unchecked{
        require(a==ownerOf(c)||getApproved(c)==a||isApprovedForAll(ownerOf(c),a));
        _tokenApprovals[c]=address(0);
        for(uint i=0;i<tokens[a].length;i++)if(tokens[a][i]==c){
            tokens[a][i]=tokens[a][tokens[a].length-1];
            tokens[a].pop();
        }
        tokens[b].push(c);
        (owl[c].parent1,owl[c].parent2,owl[c].owner)=(0,0,b);
        emit Approval(ownerOf(c),b,c);
        emit Transfer(a,b,c);
    }}
    function tokenURI(uint a)external view override returns(string memory){
        return string(abi.encodePacked("ipfs://",owl[a].cid));
    }
    function PLAYERITEMS(address a)external view returns(uint[]memory r){unchecked{
        (uint l,uint j)=(tokens[a].length,0);
        r=new uint[](l*7);
        for(uint i=0;i<l;i++){
            uint[]memory t=tokens[a];
            OWL memory o=owl[t[i]];
            (r[j]=o.parent1,j++,r[j]=o.parent2,j++,r[j]=o.time,j++,r[j]=o.gen,j++,r[j]=o.sex,j++);
            (r[j]=t[i],j++,r[j]=gen[o.gen+1].currentCount<gen[o.gen+1].maxCount?1:0,j++);
        }
    }}
    function DISTRIBUTE()external payable{unchecked{
        uint ac=address(this).balance/count;
        (bool s,)=payable(payable(_owner)).call{value:address(this).balance*(gen[1].currentCount<168?95:5)/100}("");
        for(uint i=1;i<=count;i++)(s,)=payable(payable(owl[i].owner)).call{value:ac}("");
    }}
    function _mint(address a,uint b,string memory c)private{unchecked{
        require(gen[b].currentCount<gen[b].maxCount);
        (count++,gen[b].currentCount++,owl[count].owner=a,owl[count].gen=b,owl[count].cid=c);
        tokens[a].push(count);
        emit Transfer(address(0),msg.sender,count);
    }}
    function AIRDROP(address[]memory a,string[]memory b)external{unchecked{
        require(_owner==msg.sender);
        for(uint i=0;i<a.length;i++)_mint(a[i],1,b[i]);
    }}
    function MINT(string memory r)external payable{unchecked{
        require(msg.value>=0/*.88*/ ether);
        _mint(msg.sender,1,r);
    }}
    function BREED(uint a,uint b,string memory c)external payable{unchecked{
        (OWL memory op,OWL memory oq,uint[]memory t,uint existed)=(owl[a],owl[b],tokens[msg.sender],0);
        for(uint i=0;t.length>i;i++)
        if(((owl[t[i]].parent1==a&&owl[t[i]].parent2==b)||(owl[t[i]].parent2==a&&owl[t[i]].parent1==b)))existed=1;
        require(existed==0); //Not minted by same owner
        require(op.gen==oq.gen); //Same gen
        require(op.owner==msg.sender);
        require(oq.owner==msg.sender); //Is owner of parents
        require(op.sex==2&&oq.sex==1||oq.sex==2&&op.sex==1); //Different sex
        require(op.time+0/*7*/ days<block.timestamp);
        require(oq.time+0/*7*/ days<block.timestamp); //Rested 7 days
        IPOT(ipot).BURN(msg.sender,/*3*/0); //must have 30 POT token
        _mint(msg.sender,op.gen+1,c);
        (owl[count].parent1=a,owl[count].parent2=b,owl[a].time=owl[b].time=block.timestamp);
    }}
    function REVEAL(uint a,uint b,string memory c)external{unchecked{
        require(msg.sender==owl[a].owner);
        (owl[a].sex,owl[a].cid)=(b,c);
    }}
}