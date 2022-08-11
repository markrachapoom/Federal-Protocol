import { NextPage } from "next";
import React, { FC, useState, useEffect } from "react";

// CHakra UI
import {
  Box,
  Button,
  Flex,
  HStack,
  Image,
  setScript,
  Text,
  VStack,
} from "@chakra-ui/react";
import { AppContainer } from "src/components/appContainer";

import { HiClock } from "react-icons/hi";
import { useContractRead } from "wagmi";
import escrow_abi from "../repositories/abi2.json";
import { escrowContractAddress } from "../repositories/constants";

const Judge: NextPage = () => {
  const { data, isError, isLoading } = useContractRead({
    addressOrName: escrowContractAddress,
    contractInterface: escrow_abi,
    functionName: "beneficiary",
    onError(error) {
      console.log("Error", error);
    },
    onSuccess(data) {
      console.log(data);
    },
  });

  useEffect(() => {
    // console.log(data);
    // console.log(isError);
    // console.log(isLoading);
  }, []);

  const companies = [
    {
      payer: "0x8e30b443da876487b146f783a5e5252da90b642e",
      beneficiary: "0x8E30B443da876487b146f783a5e5252dA90B642E",
      approvedBalance: "12ETH",
      status: "completed",
      imageURI:
        "https://images.unsplash.com/photo-1579547621706-1a9c79d5c9f1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80",
    },
    {
      payer: "0x8e30b443da876487b146f783a5e5252da90b642e",
      beneficiary: "0x8E30B443da876487b146f783a5e5252dA90B642E",
      approvedBalance: "1.3ETH",
      status: "completed",
      imageURI:
        "https://images.unsplash.com/photo-1557683311-eac922347aa1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2329&q=80",
    },
    {
      payer: "0x8e30b443da876487b146f783a5e5252da90b642e",
      beneficiary: "0x8E30B443da876487b146f783a5e5252dA90B642E",
      approvedBalance: "4ETH",
      status: "waiting for judge",
      imageURI:
        "https://images.unsplash.com/photo-1557682224-5b8590cd9ec5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2329&q=80",
    },
    {
      payer: "0x8e30b443da876487b146f783a5e5252da90b642e",
      beneficiary: "0x8E30B443da876487b146f783a5e5252dA90B642E",
      status: "waiting for judge",
      approvedBalance: "0.1ETH",
      imageURI:
        "https://images.unsplash.com/photo-1557682260-96773eb01377?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2329&q=80",
    },
    {
      payer: "0x8e30b443da876487b146f783a5e5252da90b642e",
      beneficiary: "0x8E30B443da876487b146f783a5e5252dA90B642E",
      status: "processing",
      approvedBalance: "0.1ETH",
      imageURI:
        "https://images.unsplash.com/photo-1557683316-973673baf926?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2329&q=80",
    },
    {
      payer: "0x8e30b443da876487b146f783a5e5252da90b642e",
      beneficiary: "0x8E30B443da876487b146f783a5e5252dA90B642E",
      status: "processing",
      approvedBalance: "0.1ETH",
      imageURI:
        "https://images.unsplash.com/photo-1569982175971-d92b01cf8694?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1335&q=80",
    },
  ];

  const [currentTab, setCurrentTab] = useState("completed");

  return (
    <AppContainer>
      <VStack maxWidth={"960px"} width={"100%"} gap={"2em"}>
        {/* BUTTONS ROW */}

        <Flex
          fontSize="5xl"
          fontWeight="bold"
          lineHeight="shorter"
          justifyContent={"flex-start"}
          width={"100%"}
        >
          Company List
        </Flex>

        <Flex justifyContent={"flex-start"} width={"100%"} gap={"1em"}>
          {/* WAITING FOR JUDGE */}
          <Button
            backgroundColor={
              currentTab === "waiting for judge" ? "black" : "transparent"
            }
            color={currentTab === "waiting for judge" ? "white" : "black"}
            borderRadius={999}
            borderColor={"background.lightGray"}
            borderWidth={"3px"}
            onClick={() => {
              setCurrentTab("waiting for judge");
            }}
          >
            Waiting for judge
          </Button>

          {/* PROCESSING */}
          <Button
            backgroundColor={
              currentTab === "processing" ? "black" : "transparent"
            }
            color={currentTab === "processing" ? "white" : "black"}
            borderRadius={999}
            borderColor={"background.lightGray"}
            borderWidth={"3px"}
            onClick={() => {
              setCurrentTab("processing");
            }}
          >
            Processing
          </Button>

          {/* COMPLETED */}
          <Button
            backgroundColor={
              currentTab === "completed" ? "black" : "transparent"
            }
            color={currentTab === "completed" ? "white" : "black"}
            borderRadius={999}
            borderColor={"background.lightGray"}
            borderWidth={"3px"}
            onClick={() => {
              setCurrentTab("completed");
            }}
          >
            Completed
          </Button>
        </Flex>

        <Flex width={"100%"} direction={"column"} gap={"2em"}>
          {companies
            .filter((company) => {
              return company.status == currentTab;
            })
            .map((company) => {
              return (
                <CompanyStatus
                  key={company.payer}
                  payer={company.payer}
                  beneficiary={company.beneficiary}
                  balance={company.approvedBalance}
                  status={company.status}
                  imageURI={company.imageURI}
                />
              );
            })}
        </Flex>
      </VStack>
    </AppContainer>
  );
};

const CompanyStatus: FC<{
  payer: any;
  beneficiary: any;
  balance: any;
  status: any;
  imageURI: any;
}> = ({ payer, beneficiary, balance, status, imageURI }) => {
  return (
    <Flex
      justifyContent={"space-between"}
      alignItems={"center"}
      direction={"column"}
      background={"background.lightGray"}
      paddingX={18}
      paddingY={21}
      borderRadius={8}
      margin={10}
    >
      {/* COMPANY INFO */}
      <Flex direction={"row"} alignItems={"center"} gap={21}>
        {/* COMPANY IMAGE */}
        <Text fontWeight={"bold"} fontSize={"1.15em"}>
          Payer:
        </Text>
        <Box borderRadius={999}>
          <Image
            src={imageURI}
            width={"35px"}
            height={"35px"}
            borderRadius={999}
          />
        </Box>

        <Text fontWeight={"bold"} fontSize={"1.15em"}>
          {payer}
        </Text>
      </Flex>

      <Flex direction={"row"} alignItems={"center"} gap={21}>
        <Text fontWeight={"bold"} fontSize={"1.15em"}>
          Beneficiary:
        </Text>
        {/* COMPANY IMAGE */}
        <Box borderRadius={999}>
          <Image
            src={imageURI}
            width={"35px"}
            height={"35px"}
            borderRadius={999}
          />
        </Box>

        <Text fontWeight={"bold"} fontSize={"1.15em"}>
          {beneficiary}
        </Text>
      </Flex>

      {status === "waiting for judge" ? (
        <Button
          mt="30px"
          backgroundColor={"text.blue"}
          borderRadius={999}
          textColor={"white"}
        >
          Approve
        </Button>
      ) : (
        <></>
      )}

      {/* CURRENT STATUS */}
      {status === "waiting for judge" && (
        <HStack mt="20px">
          <HiClock
            // backgroundColor={""}
            color={"#FFCC00"}
            width={"10px"}
            height={"10px"}
          />
          <Text fontSize={"1em"} fontWeight={"semibold"}>
            {status}
          </Text>
        </HStack>
      )}

      <Text fontSize={"1em"} fontWeight={"semibold"} mt="10px">
        Approved Token Balance: {balance}
      </Text>
    </Flex>
  );
};

export default Judge;
