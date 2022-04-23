pragma solidity^0.8.13;//SPDX-License-Identifier:MIT
interface IERC721{event Transfer(address indexed from,address indexed to,uint256 indexed tokenId);event Approval(address indexed owner,address indexed approved,uint256 indexed tokenId);event ApprovalForAll(address indexed owner,address indexed operator,bool approved);function balanceOf(address owner)external view returns(uint256 balance);function ownerOf(uint256 tokenId)external view returns(address owner);function safeTransferFrom(address from,address to,uint256 tokenId)external;function transferFrom(address from,address to,uint256 tokenId)external;function approve(address to,uint256 tokenId)external;function getApproved(uint256 tokenId)external view returns(address operator);function setApprovalForAll(address operator,bool _approved)external;function isApprovedForAll(address owner,address operator)external view returns(bool);function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data)external;}
interface IERC721Metadata{function name()external view returns(string memory);function symbol()external view returns(string memory);function tokenURI(uint256 tokenId)external view returns(string memory);}
interface IOwlWarLand{function MINT(address _t,uint256 _a)external;} 
contract ERC721AC is IERC721,IERC721Metadata{
    address private _owner;
    mapping(uint256=>address)private _tokenApprovals;
    struct Player{
        mapping(uint256=>uint256[])item; //0-lumberjack 1-miner 2-farmer 3-blacksmith 4-refinery 5-barrack 6-tower
        uint256 wood;
        uint256 metal;
        uint256 food;
        uint256 ingot;
        uint256 soldier;
        uint256 balance;
        uint256 lastClaimed;
    }
    struct NFT{
        address owner;
        uint256 item;
        uint256 level;
    }
    uint256 private _count;
    mapping(address=>bool)private _access;
    mapping(uint256=>mapping(uint256=>string))cidURI; //item,level,cid
    mapping(address=>Player)public player;
    mapping(uint256=>NFT)public nft;
    IOwlWarLand private iOWL;
    modifier onlyAccess(){require(_access[msg.sender]);_;}
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    constructor(){
        _owner=msg.sender;
        _access[msg.sender]=true;
    }
    function supportsInterface(bytes4 f)external pure returns(bool){return f==type(IERC721).interfaceId||f==type(IERC721Metadata).interfaceId;}
    function balanceOf(address o)external view override returns(uint256){return player[o].balance;}
    function ownerOf(uint256 k)public view override returns(address){return nft[k].owner;}
    function owner()external view returns(address){return _owner;}
    function approve(address t,uint256 k)external override{require(msg.sender==ownerOf(k)||isApprovedForAll(ownerOf(k),msg.sender));_tokenApprovals[k]=t;emit Approval(ownerOf(k),t,k);}
    function getApproved(uint256 tokenId)public view override returns(address){return _tokenApprovals[tokenId];}
    function setApprovalForAll(address p,bool a)external override{_operatorApprovals[msg.sender][p]=a;emit ApprovalForAll(msg.sender,p,a);}
    function isApprovedForAll(address o,address p)public view override returns(bool){return _operatorApprovals[o][p];}
    function name()external pure override returns(string memory){return"Owl Defense";}
    function symbol()external pure override returns(string memory){return"OD";}
    function safeTransferFrom(address f,address t,uint256 k)external override{transferFrom(f,t,k);}
    function safeTransferFrom(address f,address t,uint256 k,bytes memory d)external override{d=d;transferFrom(f,t,k);}
    function transferFrom(address f,address t,uint256 k)public override{unchecked{
        require(f==ownerOf(k)||getApproved(k)==f||isApprovedForAll(ownerOf(k),f));
        _tokenApprovals[k]=address(0);
        emit Approval(ownerOf(k),t,k);
        nft[k].owner=t;
        for(uint256 i=0;i<player[f].item[nft[k].item].length;i++){
            if(player[f].item[nft[k].item][i]==k){
                player[f].item[nft[k].item][i]=
                player[f].item[nft[k].item][player[f].item[nft[k].item].length-1];
                player[f].item[nft[k].item].pop();
            }
        }
        player[t].item[nft[k].item].push(k);
        player[f].balance--;
        player[f].balance++;
        autoMerge(nft[k].item,nft[k].level,t);
        CLAIM(f);
        CLAIM(t);
        emit Transfer(f,t,k);


    }}
    function setURI(uint256 t,uint256 l,string memory c)external onlyAccess{
        cidURI[t][l]=c;
    }
    function _getCount(uint256[]memory k,uint256 m)private view returns(uint256){unchecked{
        uint256 c;
        for(uint256 i=0;i<k.length;i++)c+=m*3**(nft[k[i]].level-1)*(80+nft[k[i]].level*20)/100;
        return c;
    }}
    function TokenAddress(address a)external onlyAccess{
        iOWL=IOwlWarLand(a);
    }
    function tokenURI(uint256 k)external view override returns(string memory){
        return string(abi.encodePacked("ipfs://",cidURI[nft[k].item][nft[k].level]));
    }
    function MINT(uint256 _i)external payable{unchecked{
        require(msg.value>=0/*.05 DEVELOPMENT UNCOMMENT THIS*/ ether);
        _count++;
        player[msg.sender].item[_i].push(_count);
        player[msg.sender].balance++;
        nft[_count].owner=msg.sender;
        nft[_count].item=_i;
        nft[_count].level=1;
        emit Transfer(address(0),msg.sender,_count);
        autoMerge(_i,1,msg.sender);
        CLAIM(msg.sender);
    }}
    function PLAYERITEMS(address a)external view returns(uint256[]memory,uint256[]memory){unchecked{
        uint256[]memory _items=new uint256[](player[a].balance);
        uint256[]memory _levels=new uint256[](player[a].balance);
        uint256 k;
        for(uint256 i=0;i<7;i++)for(uint256 j=0;j<player[a].item[i].length;j++){
            _items[k]=i;
            _levels[k]=nft[player[a].item[i][j]].level;
            k++;
        }
        return(_items,_levels);
    }}
    function CLAIM(address a)public{unchecked{
        uint256 _lc=player[a].lastClaimed;
        uint256 lapsedLoop=(block.timestamp-_lc)/60; //criteria for new and claimable player, 6 hours
        if(lapsedLoop>0){ 
            if(_lc>0){ //only claim when not a new player
                player[a].wood+=_getCount(player[a].item[0],3)*lapsedLoop;
                player[a].metal+=_getCount(player[a].item[1],3)*lapsedLoop;
                player[a].food+=_getCount(player[a].item[2],3)*lapsedLoop;
                uint256 counts;
                uint256 minTriple=player[a].wood<=player[a].metal? //check which one has the least quantity
                    player[a].wood<=player[a].food?player[a].wood:player[a].food:
                    player[a].metal<=player[a].food?player[a].metal:player[a].food;
                if(minTriple>2&&player[a].item[3].length>0){ //have at least 3 resource each and 1 factory
                    counts=_getCount(player[a].item[3],3)*lapsedLoop/3;
                    minTriple*=lapsedLoop/3; //conversion to owl proportional to the number of factories
                    minTriple=minTriple<=counts?counts:minTriple;
                    player[a].ingot+=minTriple;
                    player[a].wood-=minTriple*3; //deduct only those converted resources
                    player[a].metal-=minTriple*3;
                    player[a].food-=minTriple*3;
                }
                counts=0;
                minTriple=0;
                if(player[a].ingot>2&&player[a].item[4].length>0){ //have at least 3 owls and 1 house
                    counts=_getCount(player[a].item[4],3)*lapsedLoop/3;
                    minTriple=player[a].ingot*lapsedLoop/3;
                    minTriple=minTriple<=counts?counts:minTriple;
                    iOWL.MINT(msg.sender,10);
                    player[a].ingot-=minTriple*3;
                }
                player[a].soldier+=_getCount(player[a].item[5],1)*lapsedLoop;
            }
            player[a].lastClaimed=block.timestamp; //reset claimed time
        }
    }}
    function autoMerge(uint256 _i,uint256 _l,address a)private{unchecked{
        bool isMerge=true;
        while(isMerge){
            isMerge=false;
            uint256[3] memory levelCount;
            uint256 j=0;
            for(uint256 i=0;i<player[a].item[_i].length;i++){
                if(nft[player[a].item[_i][i]].level==_l){
                    if(j<levelCount.length)levelCount[j]=player[a].item[_i][i];
                    j++;
                    if(j==levelCount.length){
                        for(uint256 k=0;k<levelCount.length;k++){
                            delete nft[levelCount[k]]; //REMIX: can't get back gas fee
                            emit Approval(a,address(0),levelCount[k]);
                            for(uint256 l=0;l<player[a].item[_i].length;l++){
                                if(player[a].item[_i][l]==levelCount[k]){
                                    player[a].item[_i][l]=player[a].item[_i][player[a].item[_i].length-1];
                                    player[a].item[_i].pop(); //REMIX: can't get back gas fee
                                }
                            }
                            levelCount[k]=0;
                        }
                        _count++;
                        _l++;
                        player[a].item[_i].push(_count);
                        player[a].balance-=2; //REMIX: if can't burn this will get error
                        nft[_count].owner=a;
                        nft[_count].item=_i;
                        nft[_count].level=_l;
                        emit Approval(address(0),a,_count);
                        isMerge=true;
                    }
                }   
            }
        }
    }}
    function ATTACK(address a)external{unchecked{
        CLAIM(a);
        uint256 _defense=_getCount(player[a].item[5],2);
        if(player[msg.sender].soldier>0){ //only attack when there is soldier
            if(_defense>=player[msg.sender].soldier)player[msg.sender].soldier=0;
            else{
                player[msg.sender].soldier-=_defense;
                uint256 counts=player[msg.sender].soldier>=player[a].ingot?player[msg.sender].soldier:player[a].ingot;
                player[msg.sender].soldier-=counts;
                player[msg.sender].ingot+=counts;
                player[a].ingot-=counts;
                counts=player[msg.sender].soldier>=player[a].food?player[msg.sender].soldier:player[a].food;
                if(counts>0){                
                    player[msg.sender].soldier-=counts;
                    player[msg.sender].food+=counts;
                    player[a].food-=counts;
                    counts=player[msg.sender].soldier>=player[a].metal?player[msg.sender].soldier:player[a].metal;
                    if(counts>0){                
                        player[msg.sender].soldier-=counts;
                        player[msg.sender].metal+=counts;
                        player[a].metal-=counts;
                        counts=player[msg.sender].soldier>=player[a].wood?player[msg.sender].soldier:player[a].wood;
                        if(counts>0){                
                            player[msg.sender].soldier-=counts;
                            player[msg.sender].wood+=counts;
                            player[a].wood-=counts;
                        }
                    }
                }
            }
        }
    }}
}

/*owl multiplier only attack & defense
soldier die too
add defense
clan features
*/