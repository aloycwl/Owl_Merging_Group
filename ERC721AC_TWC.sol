pragma solidity^0.8.13;//SPDX-License-Identifier:None
interface IERC721{event Transfer(address indexed from,address indexed to,uint256 indexed tokenId);event Approval(address indexed owner,address indexed approved,uint256 indexed tokenId);event ApprovalForAll(address indexed owner,address indexed operator,bool approved);function balanceOf(address owner)external view returns(uint256 balance);function ownerOf(uint256 tokenId)external view returns(address owner);function safeTransferFrom(address from,address to,uint256 tokenId)external;function transferFrom(address from,address to,uint256 tokenId)external;function approve(address to,uint256 tokenId)external;function getApproved(uint256 tokenId)external view returns(address operator);function setApprovalForAll(address operator,bool _approved)external;function isApprovedForAll(address owner,address operator)external view returns(bool);function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data)external;}
interface IERC721Metadata{function name()external view returns(string memory);function symbol()external view returns(string memory);function tokenURI(uint256 tokenId)external view returns(string memory);}
interface IPOT{function BURN(address _t,uint256 _a)external;}
contract ERC721AC_TheWoobeingClub is IERC721,IERC721Metadata{
    uint256 public count;
    address private _owner;
    mapping(uint256=>GEN)public gen;
    mapping(uint256=>OWL)private owl;
    mapping(address=>uint256[])private tokens;
    mapping(uint256=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    IPOT private ipot;
    struct OWL{
        address owner;
        uint256 parent1;
        uint256 parent2;
        uint256 time;
        uint256 gen;
        uint256 sex;
        string cid;
    }
    struct GEN{
        uint256 maxCount;
        uint256 currentCount;
    }
    modifier onlyOwner(){require(_owner==msg.sender);_;}
    constructor(){
        _owner=msg.sender;
        gen[1].maxCount=168;
        gen[2].maxCount=1680;//TESTING VARIABLES
    }
    function supportsInterface(bytes4 f)external pure returns(bool){return f==type(IERC721).interfaceId||f==type(IERC721Metadata).interfaceId;}
    function balanceOf(address o)external view override returns(uint256){return tokens[o].length;}
    function ownerOf(uint256 k)public view override returns(address){return owl[k].owner;}
    function owner()external view returns(address){return _owner;}
    function name()external pure override returns(string memory){return"The Woobeing Club";}
    function symbol()external pure override returns(string memory){return"TWC";}
    function approve(address t,uint256 k)external override{require(msg.sender==ownerOf(k)||isApprovedForAll(ownerOf(k),msg.sender));_tokenApprovals[k]=t;emit Approval(ownerOf(k),t,k);}
    function getApproved(uint256 tokenId)public view override returns(address){return _tokenApprovals[tokenId];}
    function setApprovalForAll(address p,bool a)external override{_operatorApprovals[msg.sender][p]=a;emit ApprovalForAll(msg.sender,p,a);}
    function isApprovedForAll(address o,address p)public view override returns(bool){return _operatorApprovals[o][p];}
    function safeTransferFrom(address f,address t,uint256 k)external override{transferFrom(f,t,k);}
    function safeTransferFrom(address f,address t,uint256 k,bytes memory d)external override{d=d;transferFrom(f,t,k);}
    function transferFrom(address f,address t,uint256 k)public override{unchecked{
        require(f==ownerOf(k)||getApproved(k)==f||isApprovedForAll(ownerOf(k),f));
        _tokenApprovals[k]=address(0);
        emit Approval(ownerOf(k),t,k);
        for(uint256 i=0;i<tokens[f].length;i++)if(tokens[f][i]==k){
            tokens[f][i]=tokens[f][tokens[f].length-1];
            tokens[f].pop();
            break;
        }
        tokens[t].push(k);
        owl[k].parent1=owl[k].parent2=0;
        owl[k].owner=t;
        emit Transfer(f,t,k);
    }}
    function tokenURI(uint256 k)external view override returns(string memory){
        return string(abi.encodePacked("ipfs://",owl[k].cid));
    }
    function PLAYERITEMS(address a)external view returns(uint256[]memory r0,uint256[]memory r1,uint256[]memory r2,uint256[]memory r3,uint256[]memory r4,uint256[]memory r5,uint256[]memory r6){unchecked{
        uint256[]memory arr=tokens[a];
        uint256 l=arr.length;
        uint256 ai;
        r0=new uint256[](l);
        r1=new uint256[](l);
        r2=new uint256[](l);
        r3=new uint256[](l);
        r4=new uint256[](l);
        r5=new uint256[](l);
        r6=new uint256[](l);
        OWL memory o;
        GEN memory g;
        for(uint256 i=0;i<l;i++){
            ai=arr[i];
            o=owl[ai];
            g=gen[o.gen+1];
            r0[i]=o.parent1;
            r1[i]=o.parent2;
            r2[i]=o.time;
            r3[i]=o.gen;
            r4[i]=o.sex;
            r5[i]=ai;
            r6[i]=g.currentCount<g.maxCount?1:0;
        }
    }}
    function getBalance()external view returns(uint256){
        return address(this).balance;
    }
    function SetCid(uint256 k,string memory s)external{
        owl[k].cid=s;
    }
    function TokenAddress(address a)external onlyOwner{
        ipot=IPOT(a);
    }
    function GENPREP(uint256 k, uint256 m)external onlyOwner{
        gen[k].maxCount=m;
    }
    function DISTRIBUTE()external payable{unchecked{
        bool s;
        (s,)=payable(payable(_owner)).call{value:address(this).balance*(gen[1].currentCount<168?95:5)/100}("");
        for(uint256 i=1;i<=count;i++){
            (s,)=payable(payable(owl[i].owner)).call{value:address(this).balance/count}("");
        }
        s=s;
    }}
    function _mint(address a, uint256 g,uint256 s,string memory r)private{unchecked{
        require(gen[g].currentCount<gen[g].maxCount);
        count++;
        gen[g].currentCount++;
        owl[count].owner=a;
        owl[count].sex=s;
        owl[count].cid=r;
        owl[count].gen=g;
        tokens[a].push(count);
        emit Transfer(address(0),msg.sender,count);
    }}
    function AIRDROP(address a,uint256 s,string memory r)external onlyOwner{
        _mint(a,1,s,r);
    }
    function MINT(uint256 s,string memory r)external payable{unchecked{
        require(msg.value>=0/*.88*/ ether);
        _mint(msg.sender,1,s,r);
    }}
    function BREED(uint256 p,uint256 q,uint256 s,string memory r)external payable{unchecked{
        address m=msg.sender;
        uint256[]memory t=tokens[m];
        bool existed;
        uint256 bt=block.timestamp;
        OWL memory op=owl[p];
        OWL memory oq=owl[q];
        uint256 og=op.gen;
        for(uint256 i=0;t.length>i;i++)
        if(((owl[t[i]].parent1==p&&owl[t[i]].parent2==q)||(owl[t[i]].parent2==p&&owl[t[i]].parent1==q))){
            existed=true;
            break;
        }
        require(!existed&& //never mint before
            og==oq.gen&& //must be same gen
            op.owner==m&&oq.owner==m&& //must only owner of p and q
            (op.sex==0&&oq.sex==1||oq.sex==0&&op.sex==1)&& //must be different sex
            op.time+0<bt&&oq.time+0/*7*/ days<bt);//time
        //ipot.BURN(m,/*3*/0); //must have 30 OWL token
        _mint(m,og+1,s,r);
        owl[count].parent1=p;
        owl[count].parent2=q;
        owl[p].time=owl[q].time=bt;
    }}
}
