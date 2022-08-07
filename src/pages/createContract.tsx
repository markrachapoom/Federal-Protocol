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
} from "@chakra-ui/react";
import { Icon } from "@chakra-ui/react";
import { CheckIcon } from "@chakra-ui/icons";
import { AppContainer } from "src/components/appContainer";
import { useAccount, useConnect, useDisconnect, useSignMessage } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";

const LoginPage: NextPage = () => {
  const { address, isConnected } = useAccount();
  const [signerAddress, setSignerAddress] = useState<string>();
  const [judgeAddress, setJudgeAddress] = useState<string>();
  const { connect } = useConnect({
    chainId: 137,
    connector: new InjectedConnector(),
    onSuccess(data) {
      console.log(data);
    },
  });
  const { disconnect } = useDisconnect();

  useEffect(() => {}, []);

  return (
    <AppContainer>
      <Flex w="full" direction="column">
        <Box color="text.black" textAlign="left">
          <Box fontSize="5xl" fontWeight="bold" lineHeight="shorter">
            Create Contract
          </Box>
        </Box>
        <Box
          fontSize="2xl"
          color="text.black"
          textAlign="center"
          h="140px"
          alignItems="center"
          display="flex"
          justifyContent="center"
        >
          Begin your contract in 4 easy steps...
        </Box>
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
                  variant="unstyled"
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
                />
              </InputGroup>
            </Box>
          </Box>
        </VStack>
        <Button
          mt="66px"
          px={4}
          py={3}
          h="auto"
          backgroundColor="text.blue"
          fontWeight="bold"
          alignItems="center"
          textColor="white"
          variant="box"
          rounded="full"
        >
          Create
        </Button>
      </Flex>
    </AppContainer>
  );
};

export default LoginPage;
