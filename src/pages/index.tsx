import {
    Box,
    Button,
    Flex,
    GridItem,
    Icon,
    Image,
    SimpleGrid,
    Text,
  } from "@chakra-ui/react";
  import type { NextPage } from "next";
  import React, { useCallback, useEffect, useState } from "react";
  import { AppContainer } from "src/components/appContainer";
  import { contractAddress } from "../repositories/constants";
  import abi from "../repositories/abi.json";
  import { useBalance, useContractRead, useContractWrite } from "wagmi";
  
  const Dashboard: NextPage = () => {
    
    useEffect(() => {
    }, []);
  
    return (
      <AppContainer>
        <Flex w="full" direction="column" align="left">
          <Box color="text.white" textAlign="left">
          </Box>
        </Flex>
      </AppContainer>
    );
  };
  
  export default Dashboard;
  