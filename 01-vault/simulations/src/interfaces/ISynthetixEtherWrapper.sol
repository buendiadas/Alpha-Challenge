// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ISynthetixEtherWrapper {
    function mint(uint amount) external;

    function burn(uint amount) external;

    function distributeFees() external;

    function capacity() external view returns (uint);

    function getReserves() external view returns (uint);

    function totalIssuedSynths() external view returns (uint);

    function calculateMintFee(uint amount) external view returns (uint);

    function calculateBurnFee(uint amount) external view returns (uint);

    function maxETH() external view returns (uint256);

    function mintFeeRate() external view returns (uint256);

    function burnFeeRate() external view returns (uint256);

}