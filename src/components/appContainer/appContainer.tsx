import { Box, Flex, FlexProps } from "@chakra-ui/react";
import { Header } from "../header";

type Props = {children: any };

export const AppContainer: React.FC<Props> = ({ children, ...flexProps }) => {
  return (
    <>
      <Header />
      <Flex
        w="960px"
        minH="100vh"
        px={24}
        pt={32}
        pb={16}
        direction="column"
        align="center"
        background="background.white"
        {...flexProps}
      >
        {children}
      </Flex>
    </>
  );
};
