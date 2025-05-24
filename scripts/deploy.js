async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying DigitalArtNFT with account:", deployer.address);

  const DigitalArtNFT = await ethers.getContractFactory("DigitalArtNFT");
  const platformFeeRecipient = deployer.address; // can be changed

  const digitalArtNFT = await DigitalArtNFT.deploy("DigitalArtNFT", "DANFT", platformFeeRecipient);

  await digitalArtNFT.deployed();

  console.log("DigitalArtNFT deployed to:", digitalArtNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
