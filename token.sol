// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20{

    //getters
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    //functions
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    //events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256);

}

contract NMGToken is IERC20{

    string public constant name = "NMG Token";
    string public constant symbol = "NMG";
    uint8 public constant decimals = 18;

    mapping (address => uint256) balances;

    mapping(address => mapping(address=>uint256)) allowed;

    uint256 totalSupply_ = 10 ether;

    constructor(){
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]); //testando pra ver se é possível ele enviar o valor (se possui saldo suficiente)
        balances[msg.sender] = balances[msg.sender]-numTokens;//enviador do valor está tendo valor decrementado da sua conta
        balances[receiver] = balances[receiver]+numTokens; //recebedor do valor está tendo valor incrementado em sua conta
        emit Transfer(msg.sender, receiver, numTokens); //emitindo sinal de estado para possíveis atualizações em D'apps
        return true; //retorno true caso feita transferência corretamente
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens; //autoriza o delegado a casatar num tokens de sua conta
        emit Approval(msg.sender, delegate, numTokens); //emite evento que é registrado na blockchain
        return true; //se ocorrer conforme, retorna true
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate]; //retorna o valor que o delegado pode gastar do owner
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]); //verificando se o dono do valor tem saldo suficiente para a transferência em questão
        require(numTokens <= allowed[owner][msg.sender]); //verificando se sender tem permissão pra enviar este valor específico da conta owner (allowed é um mapeamento que mostra valor que um endereço está autorizado a gastar de um outro endereço)

        balances[owner] = balances[owner]-numTokens; //Subtrai o número de tokens transferidos do saldo do owner.
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens; //Atualiza a quantidade de tokens que msg.sender ainda pode transferir do owner após a transferência.
        balances[buyer] = balances[buyer]+numTokens; //Adiciona os tokens ao saldo do buyer.
        emit Transfer(owner, buyer, numTokens); // Emite um evento Transfer que é registrado na blockchain. Esse evento é usado para notificar aplicativos e interfaces sobre a transação de tokens.
        return true; // Retorna true para indicar que a função foi executada com sucesso.
    }

}