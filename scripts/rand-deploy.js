async function main() {
  const RandomNum = await ethers.getContractFactory("RandomNum");
  const randomNum = await RandomNum.deploy()
  console.log("Random Num deployed to:", randomNum.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });