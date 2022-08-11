import type { NextPage } from "next";
import React, { useCallback, useEffect, useRef, useState } from "react";
import {
  Box,
  Button,
  Flex,
  Image,
  Spacer,
  Text,
  VStack,
  HStack,
  FormControl,
  FormLabel,
  FormHelperText,
  Input,
  InputGroup,
  InputLeftElement,
  InputRightElement,
  useToast,
  Alert,
  AlertIcon,
  AlertDescription,
  AlertTitle,
  Spinner,
  Link,
} from "@chakra-ui/react";
import { Icon } from "@chakra-ui/react";
import { CheckIcon, ExternalLinkIcon } from "@chakra-ui/icons";
import { AppContainer } from "src/components/appContainer";
import { useAccount, useConnect, useDisconnect, useSignMessage } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";
import { NFTStorage, File } from "nft.storage";
import { useContractWrite } from "wagmi";
import {
  escrowFactoryContractAddress,
  NFTStorageToken,
  escrowContractAddress
} from "../repositories/constants";
import abi from "../repositories/abi.json";

const LoginPage: NextPage = () => {
  const toast = useToast();
  const [isVisible, setIsVisible] = useState<boolean>(false);
  const { address, isConnected } = useAccount();
  const [createdContractAddress, setCreatedContractAddress] = useState<string>(
    escrowContractAddress
  );
  const [signerAddress, setSignerAddress] = useState<string>("");
  const handleChangeSignerAddress = (
    event: React.ChangeEvent<HTMLInputElement>
  ) => setSignerAddress(event.target.value);
  const [judgeAddress, setJudgeAddress] = useState<string>("");
  const handleChangeJudgeAddress = (
    event: React.ChangeEvent<HTMLInputElement>
  ) => setJudgeAddress(event.target.value);
  const [contractNFTURI, setcontractNFTURI] = useState<string>("");
  const { connect } = useConnect({
    chainId: 137,
    connector: new InjectedConnector(),
    onSuccess(data) {
      console.log(data);
    },
  });
  const { disconnect } = useDisconnect();

  useEffect(() => {}, []);

  const {
    write: createProxy,
  } = useContractWrite({
    addressOrName: escrowFactoryContractAddress,
    contractInterface: abi,
    functionName: "createProxy",
    args: [address, signerAddress!, judgeAddress!],
    onError(error) {
      toast({
        title: error.name,
        description: error.message,
        status: "error",
        duration: 9000,
        isClosable: true,
      });
    },
    onSuccess(data) {
      setIsVisible(true);
      console.log("Success", data);
    },
    //args: ["0x886Aa330E54Fba39e342111455B1923CEd05B01D", "0x8E30B443da876487b146f783a5e5252dA90B642E", "0xD7ADf60E9057752858A27c67d1648db5FF472a45"],
  });

  async function storeAsset() {
    const imageOriginUrl = "Gangnam.JPG";
    const r = await fetch(imageOriginUrl);
    const image = r.blob();

    const client = new NFTStorage({
      token: NFTStorageToken,
    });
    const metadata = await client.store({
      name: "ContractNFT",
      description: "ContractNFT",
      image: await image,
    });
    console.log("Metadata stored on Filecoin and IPFS with URL:", metadata.url);
    setcontractNFTURI(metadata.url);
  }

  function handleUpload(event: React.ChangeEvent<HTMLInputElement>) {
    storeAsset();
  }

  function handleCreate() {
    createProxy();
  }

  return (
    <AppContainer>
      <Flex width={"100%"} maxWidth={"768px"} direction="column">
        <Box color="text.black" textAlign="left">
          <Box fontSize="5xl" fontWeight="bold" lineHeight="shorter">
            Create Contract
          </Box>
        </Box>
        <Box
          fontSize={"1.25em"}
          color={"text.gray"}
          textAlign="start"
          h="140px"
          display="flex"
          alignItems="center"
          justifyContent="flex-start"
        >
          Begin your contract in 4 easy steps...
        </Box>
        {isVisible ? (
          <Alert
            status="success"
            variant="subtle"
            flexDirection="column"
            alignItems="center"
            justifyContent="center"
            textAlign="center"
            height="380px"
            mb="80px"
          >
            <AlertIcon boxSize="40px" mr={0} />
            <AlertTitle mt={4} mb={1} fontSize="lg">
              Contract created!
            </AlertTitle>
            <AlertDescription maxWidth="sm">
              Thanks for submitting your contract. Your contract adrees is as
              blow. <br />
              <br />
              <Link color="teal.500" href="https://rinkeby.etherscan.io/address/0x9e3f54abd04a45ed6e6c5204e7f3589dcf40fea0#code" isExternal>
                {createdContractAddress} <ExternalLinkIcon mx='2px' />
              </Link> 
              <br /><br />
              Your contract NFT.
              <br />
              <Link color="teal.500" href={contractNFTURI} isExternal>
                {contractNFTURI} <ExternalLinkIcon mx='2px' />
              </Link> 
            </AlertDescription>
          </Alert>
        ) : (
          <></>
        )}

        <VStack spacing="32px" align="stretch">
          <Box>
            <Text color="text.black" fontSize="2xl" fontWeight="bold" mb="20px">
              1. Connect Wallet
            </Text>
            <Box h="56px" bg="background.lightGray" rounded="12">
              {isConnected == true ? (
                <InputGroup h="full" pl="16px">
                  <Input
                    variant="unstyled"
                    textColor="text.black"
                    value={address}
                  />
                  <InputRightElement h="full">
                    <CheckIcon color="text.blue" />
                  </InputRightElement>
                </InputGroup>
              ) : (
                <Button
                  textColor="white"
                  h="30px"
                  fontSize="12px"
                  rounded="full"
                  backgroundColor="text.blue"
                  onClick={() => connect()}
                >
                  Connect
                </Button>
              )}
            </Box>
          </Box>
          <Box>
            <Text color="text.black" fontSize="2xl" fontWeight="bold" mb="20px">
              2. Upload Contract
            </Text>
            <Box h="56px" bg="background.lightGray" rounded="12">
              <Flex h="full" pl="16px" alignItems="center">
                <Input
                  textColor="text.blue"
                  h="30px"
                  fontSize="12px"
                  type="file"
                  variant="filled"
                  onChange={handleUpload}
                />
              </Flex>
            </Box>
          </Box>
          <Box>
            <Text color="text.black" fontSize="2xl" fontWeight="bold" mb="20px">
              3. Intended Signer Address
            </Text>
            <Box h="56px" bg="background.lightGray" rounded="12">
              <InputGroup h="full" pl="16px">
                <Input
                  placeholder="Input address"
                  variant="unstyled"
                  textColor="text.black"
                  value={signerAddress}
                  onChange={handleChangeSignerAddress}
                />
              </InputGroup>
            </Box>
          </Box>
          <Box>
            <Text color="text.black" fontSize="2xl" fontWeight="bold" mb="20px">
              4. Choose Your Judge
            </Text>
            <Box h="56px" bg="background.lightGray" rounded="12">
              <InputGroup h="full" pl="16px">
                <Input
                  placeholder="Input address"
                  variant="unstyled"
                  textColor="text.black"
                  value={judgeAddress}
                  onChange={handleChangeJudgeAddress}
                />
              </InputGroup>
            </Box>
          </Box>
        </VStack>
        <Button
          mt="66px"
          px={4}
          py={3}
          h={"56px"}
          backgroundColor="text.blue"
          fontWeight="bold"
          alignItems="center"
          textColor="white"
          variant="box"
          rounded="full"
          onClick={handleCreate}
        >
          Create
        </Button>
      </Flex>
    </AppContainer>
  );
};

export default LoginPage;
