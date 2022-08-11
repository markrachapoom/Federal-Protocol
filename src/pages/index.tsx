import {
  Box,
  Button,
  Flex,
  GridItem,
  Icon,
  Image,
  SimpleGrid,
  Text,
  Link,
} from "@chakra-ui/react";
import type { NextPage } from "next";
import React, { useCallback, useEffect, useState } from "react";
import NextLink from "next/link";
import { AppContainer } from "src/components/appContainer";
import abi from "../repositories/abi.json";
import { useBalance, useContractRead, useContractWrite } from "wagmi";

const Dashboard: NextPage = () => {
  useEffect(() => {}, []);

  return (
    <AppContainer>
      <Flex
        alignSelf="stretch"
        mx={-24}
        px={24}
        mt={-32}
        pt={40}
        pb={12}
        direction="column"
        align="center"
        backgroundSize="cover"
        background="url('/background.png')"
        backgroundPosition="center"
      >
        <Flex w="full" maxW="1200px" direction="column" align="center">
          <Flex w="full" justify="space-between" align="center">
            <Flex direction="column" align="flex-start">
              <Box
                fontSize="5xl"
                fontWeight="bold"
                color="white"
                lineHeight="shorter"
              >
                Never buy or sell online<br /> without using<br /> Federal Protocol
              </Box>
              <Box
                mt={4}
                fontSize="lg"
                color="#D6D6D6"
                textShadow="overImage"
                lineHeight="shorter"
                whiteSpace="pre-wrap"
              >
                Federal Protocol is a decentralized escrow platform with <br />
                Blockchain technology. <br/>you can buy and sell anything safely trustlessly.
              </Box>
            </Flex>
          </Flex>
        </Flex>
        <NextLink href="/createContract" passHref={true}>
          <Link>
            <Box mt={120}>
              <Button
                w={60}
                h={16}
                fontSize="xl"
                fontWeight="bold"
                color="text.white"
                background="black"
                variant="invBox"
              >
                Create Contract
              </Button>
            </Box>
          </Link>
        </NextLink>
      </Flex>
    </AppContainer>
  );
};

export default Dashboard;
