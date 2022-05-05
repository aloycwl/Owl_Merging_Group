pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{event Transfer(address indexed from,address indexed to,uint indexed tokenId);event Approval(address indexed owner,address indexed approved,uint indexed tokenId);event ApprovalForAll(address indexed owner,address indexed operator,bool approved);function balanceOf(address owner)external view returns(uint balance);function ownerOf(uint tokenId)external view returns(address owner);function safeTransferFrom(address from,address to,uint tokenId)external;function transferFrom(address from,address to,uint tokenId)external;function approve(address to,uint tokenId)external;function getApproved(uint tokenId)external view returns(address operator);function setApprovalForAll(address operator,bool _approved)external;function isApprovedForAll(address owner,address operator)external view returns(bool);function safeTransferFrom(address from,address to,uint tokenId,bytes calldata data)external;}
interface IERC721Metadata{function name()external view returns(string memory);function symbol()external view returns(string memory);function tokenURI(uint tokenId)external view returns(string memory);}
interface IPOT{function BURN(address _t,uint _a)external;}
contract ERC721AC_TheWoobeingClub is IERC721,IERC721Metadata{
    uint public count;
    address private _owner;
    mapping(uint=>GEN)public gen;
    mapping(uint=>OWL)private owl;
    mapping(address=>uint[])private tokens;
    mapping(uint=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    IPOT private ipot;
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
    modifier onlyOwner(){require(_owner==msg.sender);_;}
    constructor(){
        (_owner,gen[1].maxCount,gen[2].maxCount)=(msg.sender,168,1680);//TESTING VARIABLES
    }
    function supportsInterface(bytes4 f)external pure returns(bool){return f==type(IERC721).interfaceId||f==type(IERC721Metadata).interfaceId;}
    function balanceOf(address o)external view override returns(uint){return tokens[o].length;}
    function ownerOf(uint k)public view override returns(address){return owl[k].owner;}
    function owner()external view returns(address){return _owner;}
    function name()external pure override returns(string memory){return"The Woobeing Club";}
    function symbol()external pure override returns(string memory){return"TWC";}
    function approve(address t,uint k)external override{require(msg.sender==ownerOf(k)||isApprovedForAll(ownerOf(k),msg.sender));_tokenApprovals[k]=t;emit Approval(ownerOf(k),t,k);}
    function getApproved(uint tokenId)public view override returns(address){return _tokenApprovals[tokenId];}
    function setApprovalForAll(address p,bool a)external override{_operatorApprovals[msg.sender][p]=a;emit ApprovalForAll(msg.sender,p,a);}
    function isApprovedForAll(address o,address p)public view override returns(bool){return _operatorApprovals[o][p];}
    function safeTransferFrom(address f,address t,uint k)external override{transferFrom(f,t,k);}
    function safeTransferFrom(address f,address t,uint k,bytes memory d)external override{d=d;transferFrom(f,t,k);}
    function getBalance()external view returns(uint){return address(this).balance;}
    function SetCid(uint k,string memory s)external{owl[k].cid=s;}
    function TokenAddress(address a)external onlyOwner{ipot=IPOT(a);}
    function GENPREP(uint k, uint m)external onlyOwner{gen[k].maxCount=m;}
    function transferFrom(address f,address t,uint k)public override{unchecked{
        require(f==ownerOf(k)||getApproved(k)==f||isApprovedForAll(ownerOf(k),f));
        _tokenApprovals[k]=address(0);
        emit Approval(ownerOf(k),t,k);
        for(uint i=0;i<tokens[f].length;i++)if(tokens[f][i]==k){
            tokens[f][i]=tokens[f][tokens[f].length-1];
            tokens[f].pop();
            break;
        }
        tokens[t].push(k);
        (owl[k].parent1,owl[k].parent2,owl[k].owner)=(0,0,t);
        emit Transfer(f,t,k);
    }}
    function tokenURI(uint k)external view override returns(string memory){
        return string(abi.encodePacked("ipfs://",owl[k].cid));
    }
    function PLAYERITEMS(address a)external view returns(uint[]memory r0,uint[]memory r1,uint[]memory r2,uint[]memory r3,uint[]memory r4,uint[]memory r5,uint[]memory r6){unchecked{
        uint l=tokens[a].length;
        (r0,r1,r2,r3,r4,r5,r6)=(new uint[](l),new uint[](l),new uint[](l),new uint[](l),new uint[](l),new uint[](l),new uint[](l));
        for(uint i=0;i<l;i++){
            uint[]memory t=tokens[a];
            OWL memory o=owl[t[i]];
            (r0[i],r1[i],r2[i])=(o.parent1,o.parent2,o.time);
            (r3[i],r4[i],r5[i])=(o.gen,o.sex,t[i]);
            r6[i]=gen[o.gen+1].currentCount<gen[o.gen+1].maxCount?1:0;
        }
    }}
    function DISTRIBUTE()external payable{unchecked{
        (bool s,uint ac)=(false,address(this).balance/count);
        (s,)=payable(payable(_owner)).call{value:address(this).balance*(gen[1].currentCount<168?95:5)/100}("");
        for(uint i=1;i<=count;i++)(s,)=payable(payable(owl[i].owner)).call{value:ac}("");
        s=s;
    }}
    function _mint(address a, uint g,uint s,string memory r)private{unchecked{
        require(gen[g].currentCount<gen[g].maxCount);
        (count++,gen[g].currentCount++);
        (owl[count].owner,owl[count].sex,owl[count].cid,owl[count].gen)=(a,s,r,g);
        tokens[a].push(count);
        emit Transfer(address(0),msg.sender,count);
    }}
    function AIRDROP(address a,uint s,string memory r)external onlyOwner{
        _mint(a,1,s,r);
    }
    function MINT(uint s,string memory r)external payable{unchecked{
        require(msg.value>=0/*.88*/ ether);
        _mint(msg.sender,1,s,r);
    }}
    function BREED(uint p,uint q,uint s,string memory r)external payable{unchecked{
        (OWL memory op,OWL memory oq,uint existed)=(owl[p],owl[q],0);
        (uint bt,uint[]memory t,uint og)=(block.timestamp,tokens[msg.sender],op.gen);
        for(uint i=0;t.length>i;i++)
        if(((owl[t[i]].parent1==p&&owl[t[i]].parent2==q)||(owl[t[i]].parent2==p&&owl[t[i]].parent1==q)))existed=1;
        require(existed==0); //Not minted by same owner
        require(og==oq.gen); //Same gen
        require(op.owner==msg.sender);
        require(oq.owner==msg.sender); //Is owner of parents
        require(op.sex==0&&oq.sex==1||oq.sex==0&&op.sex==1); //Different sex
        require(op.time+0<bt);
        require(oq.time+0/*7*/ days<bt); //Rested 7 days
        //ipot.BURN(m,/*3*/0); //must have 30 OWL token
        _mint(msg.sender,og+1,s,r);
        (owl[count].parent1,owl[count].parent2)=(p,q);
        owl[p].time=owl[q].time=bt;
    }}
}
