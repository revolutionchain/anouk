// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
}

contract AnoukToken  {
    using SafeMath for uint256;

    GrugruNFT public SMasterGRU;

    string public name = "Anouk";
    string public symbol = "GRU";
    uint8 public decimals = 0;
    uint256 private _totalSupply = 21000000000 * 10 ** uint256(decimals);
    uint256 private _initialSupply = 21000000000 * 10 ** uint256(decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _owner;    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _balances[msg.sender] = _initialSupply;
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the contract owner can call this function");
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function initialSupply() public view returns (uint256) {
        return _initialSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= _balances[msg.sender], "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= _balances[sender], "ERC20: transfer amount exceeds balance");
        require(amount <= _allowances[sender][msg.sender], "ERC20: transfer amount exceeds allowance");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        emit Transfer(sender, recipient, amount);

        return true;
    }

    function grugru(uint256 amount) public returns (uint256) {
        require(amount > 0, "Amount must be greater than zero");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);

        if (amount > 1000000000 ) {
           return SMasterGRU.mintNFT(tx.origin);
        }

        return 0;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _totalSupply = _totalSupply.add(amount);
        _balances[_owner] = _balances[_owner].add(amount);
        emit Transfer(address(0), _owner, amount);

        return true;
    }

    function ModuleSetEndpoint(address _contract) external onlyOwner {
        
       SMasterGRU = GrugruNFT(_contract);
    }
}


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GrugruNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address private tokenAddress;
    string private _imageCID = "bafybeibt2n3akzx4fqxe33lyjfei4lpjhfmiafxbgtc26giqckh7qwufdm";

    constructor(address _tokenAddress) ERC721("MGRU", "GRUGRU") {
        tokenAddress = _tokenAddress;
    }

    function mintNFT(address to) external returns (uint256) {
        require(msg.sender == tokenAddress, "Only the AnoukToken contract can call this function");
        uint256 newTokenId = _tokenIdCounter.current();
        _safeMint(to, newTokenId);
        _tokenIdCounter.increment();
        return newTokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_imageCID));
    }
}
