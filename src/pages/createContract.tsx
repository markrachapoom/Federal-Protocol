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
  FormControl,
  FormLabel,
  FormHelperText,
  Input,
} from "@chakra-ui/react";
import { AppContainer } from "src/components/appContainer";
import { useAccount, useConnect, useDisconnect, useSignMessage } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";

const LoginPage: NextPage = () => {
  const { isConnected } = useAccount();
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
      <Flex w="full" direction="column" align="left">
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
            <Text color="text.black" fontSize="2xl" fontWeight="bold">
              1st. Connect Wallet
            </Text>
            <Box
              h="84px"
              bg="background.lightGray"
              color="text.white"
              fontSize="2xl"
              fontWeight="bold"
            >
              <Flex h="full" p="44px" alignItems="center">
                <Image h="40px" src="/metamask.svg" alt="logo" />
                <Text pl="44px" color="text.black">
                  MetaMask
                </Text>
                <Spacer />
                {isConnected == true ? (
                  <Button
                    rounded="full"
                    backgroundColor="text.purple"
                    onClick={() => disconnect()}
                  >
                    Disconnect
                  </Button>
                ) : (
                  <Button
                    rounded="full"
                    backgroundColor="text.purple"
                    onClick={() => connect()}
                  >
                    Connect
                  </Button>
                )}
              </Flex>
            </Box>
          </Box>
          <Box>
            <Text color="text.black" fontSize="2xl" fontWeight="bold">
              Upload Contract
            </Text>
            <Box
              h="84px"
              bg="background.lightGray"
              color="text.white"
              fontSize="2xl"
              fontWeight="bold"
            ></Box>
          </Box>
          <Box>
            <Text color="text.black" fontSize="2xl" fontWeight="bold">
              Intended Signer Address
            </Text>
            <Box
              h="84px"
              bg="background.lightGray"
              color="text.white"
              fontSize="2xl"
              fontWeight="bold"
            ></Box>
          </Box>
          <Box>
            <Text color="text.black" fontSize="2xl" fontWeight="bold">
              Choose Your Judge
            </Text>
            <Box
              h="84px"
              bg="background.lightGray"
              color="text.white"
              fontSize="2xl"
              fontWeight="bold"
            ></Box>
          </Box>
        </VStack>
      </Flex>
    </AppContainer>
  );
};

export default LoginPage;
