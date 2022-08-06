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
      console.log(data)
    },
  });
  const { disconnect } = useDisconnect();


  useEffect(() => {
  }, []);

  return (
    <AppContainer>
      <Flex w="full" direction="column" align="left">
        <Box color="text.white" textAlign="left">
          <Box fontSize="5xl" fontWeight="bold" lineHeight="shorter">
            Login
          </Box>
        </Box>
        <Box
          color="text.white"
          textAlign="center"
          h="140px"
          alignItems="center"
          display="flex"
          justifyContent="center"
        >
          Connect with one of our availble wallet providers.
        </Box>
        <VStack spacing="8px" align="stretch">
          <Box
            h="84px"
            bg="background.lightGray"
            color="text.white"
            fontSize="2xl"
            fontWeight="bold"
          >
            <Flex h="full" p="44px" alignItems="center">
              <Image h="40px" src="/metamask.svg" alt="logo" />
              <Text pl="44px" color="text.black">MetaMask</Text>
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
        </VStack>
      </Flex>
    </AppContainer>
  );
};

export default LoginPage;
