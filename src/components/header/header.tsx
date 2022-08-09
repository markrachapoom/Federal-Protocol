import {
  Avatar,
  Box,
  Button,
  Flex,
  Input,
  Image,
  Link,
  InputGroup,
  InputLeftElement,
  Text,
} from "@chakra-ui/react";
import { FaSearch } from "react-icons/fa";
import NextLink from "next/link";
import { useAccount, useContractRead } from "wagmi";
import { contractAddress } from "../../repositories/constants";
import abi from "../../repositories/abi.json";
import React, { useCallback, useEffect, useState } from "react";

type Props = {};

export const Header: React.FC<Props> = ({}) => {
  const { address, isConnected } = useAccount();

  useEffect(() => {}, []);

  return (
    <Flex
      w="full"
      px={4}
      py={2}
      align="center"
      justify="space-between"
      position="absolute"
      top={0}
      background="background.lightGray"
    >
      <Box>
        <NextLink href="/" passHref={true}>
          <Link>
            <Text
              fontWeight="bold"
              textColor="text.black"
              fontSize="20px"
              ml="12px"
            >
              {" "}
              Federal Protocol
            </Text>
            {/* <Image h={5} src="/logo.svg" alt="logo" /> */}
          </Link>
        </NextLink>
      </Box>
      <Flex gap={4} align="center">
        {/* CREATE CONTRACT */}
        <NextLink href="/createContract" passHref={true}>
          <Button
            px={4}
            py={3}
            h="auto"
            fontWeight="bold"
            alignItems="center"
            variant="box"
            color="text.black"
          >
            Create Contract
          </Button>
        </NextLink>

        <NextLink href="/judge" passHref={true}>
          <Button
            px={4}
            py={3}
            h="auto"
            fontWeight="bold"
            alignItems="center"
            variant="box"
            color="text.black"
          >
            Judge
          </Button>
        </NextLink>

        {/* LOG IN */}
        <NextLink href="/login" passHref={true}>
          <Button
            px={4}
            py={3}
            h="auto"
            backgroundColor="white"
            fontWeight="bold"
            alignItems="center"
            variant="box"
            rounded="full"
          >
            <Avatar size="sm" mr={3} />
            {isConnected == true ? (
              <>{address?.slice(0, 5)}</>
            ) : (
              <>Connect Wallet</>
            )}
          </Button>
        </NextLink>
      </Flex>
    </Flex>
  );
};
