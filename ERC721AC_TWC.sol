pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{event Transfer(address indexed a,address indexed b,uint indexed c);event Approval(address indexed a,address indexed b,uint indexed c);event ApprovalForAll(address indexed a,address indexed b,bool c);function balanceOf(address a)external view returns(uint b);function ownerOf(uint a)external view returns(address b);function safeTransferFrom(address a,address b,uint c)external;function transferFrom(address a,address b,uint c)external;function approve(address a,uint b)external;function getApproved(uint a)external view returns(address b);function setApprovalForAll(address a,bool b)external;function isApprovedForAll(address a,address b)external view returns(bool);function safeTransferFrom(address a,address b,uint c,bytes calldata data)external;}
interface IERC721Metadata{function name()external view returns(string memory);function symbol()external view returns(string memory);function tokenURI(uint a)external view returns(string memory);}
interface IPOT{function BURN(address a,uint b)external;}
contract ERC721AC_TheWoobeingClub is IERC721,IERC721Metadata{
    uint public count;
    address private _owner;
    address private ipot;
    mapping(uint=>GEN)public gen;
    mapping(uint=>OWL)private owl;
    mapping(address=>uint[])private tokens;
    mapping(uint=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    struct OWL{
        address owner;
        uint parent1;
        uint parent2;
        uint time;
        uint gen;
        uint sex;
        string cid;
    }
    struct GEN{
        uint maxCount;
        uint currentCount;
    }
    constructor(){
        (_owner,gen[1].maxCount,gen[2].maxCount)=(msg.sender,168,1680);//TESTING VARIABLES
    }
    function supportsInterface(bytes4 a)external pure returns(bool){return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;}
    function balanceOf(address a)external view override returns(uint){return tokens[a].length;}
    function ownerOf(uint a)public view override returns(address){return owl[a].owner;}
    function owner()external view returns(address){return _owner;}
    function name()external pure override returns(string memory){return"The Woobeing Club";}
    function symbol()external pure override returns(string memory){return"TWC";}
    function approve(address a,uint b)external override{require(msg.sender==ownerOf(b)||isApprovedForAll(ownerOf(b),msg.sender));_tokenApprovals[b]=a;emit Approval(ownerOf(b),a,b);}
    function getApproved(uint a)public view override returns(address){return _tokenApprovals[a];}
    function setApprovalForAll(address a,bool b)external override{_operatorApprovals[msg.sender][a]=b;emit ApprovalForAll(msg.sender,a,b);}
    function isApprovedForAll(address a,address b)public view override returns(bool){return _operatorApprovals[a][b];}
    function safeTransferFrom(address a,address b,uint c)external override{transferFrom(a,b,c);}
    function safeTransferFrom(address a,address b,uint c,bytes memory d)external override{transferFrom(a,b,c);d;}
    function getBalance()external view returns(uint){return address(this).balance;}
    function setCID(uint a,string memory b)external{owl[a].cid=b;}
    function TokenAddress(address a)external{require(_owner==msg.sender);ipot=a;}
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
        uint l=tokens[a].length;
        uint j;
        r=new uint[](l*7);
        for(uint i=0;i<l;i++){
            uint[]memory t=tokens[a];
            OWL memory o=owl[t[i]];
            r[j]=o.parent1;j++;
            r[j]=o.parent2;j++;
            r[j]=o.time;j++;
            r[j]=o.gen;j++;
            r[j]=o.sex;j++;
            r[j]=t[i];j++;
            r[j]=gen[o.gen+1].currentCount<gen[o.gen+1].maxCount?1:0;j++;
        }
    }}
    function DISTRIBUTE()external payable{unchecked{
        uint ac=address(this).balance/count;
        (bool s,)=payable(payable(_owner)).call{value:address(this).balance*(gen[1].currentCount<168?95:5)/100}("");
        for(uint i=1;i<=count;i++)(s,)=payable(payable(owl[i].owner)).call{value:ac}("");
    }}
    function _mint(address a,uint b,string memory c)private{unchecked{
        require(gen[b].currentCount<gen[b].maxCount);
        (count++,gen[b].currentCount++);
        (owl[count].owner,owl[count].gen,owl[count].cid)=(a,b,c);
        tokens[a].push(count);
        emit Transfer(address(0),msg.sender,count);
    }}
    function AIRDROP(address a,string memory b)external{
        require(_owner==msg.sender);_mint(a,1,b);
    }
    function MINT(string memory r)external payable{unchecked{
        require(msg.value>=0/*.88*/ ether);
        _mint(msg.sender,1,r);
    }}
    function BREED(uint a,uint b,string memory c)external payable{unchecked{
        uint existed;
        (OWL memory op,OWL memory oq)=(owl[a],owl[b]);
        uint[]memory t=tokens[msg.sender];
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
        (owl[count].parent1,owl[count].parent2)=(a,b);
        owl[a].time=owl[b].time=block.timestamp;
    }}
    function REVEAL(uint a,uint b,string memory c)external{unchecked{
        require(msg.sender==owl[a].owner);
        owl[a].sex=b;
        owl[a].cid=c;
    }}
}
