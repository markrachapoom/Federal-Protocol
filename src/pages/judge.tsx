import { NextPage } from 'next'
import React, { FC } from 'react'

// CHakra UI
import {
    Box,
    Flex,
    Image,
    Text,
    VStack
} from '@chakra-ui/react';
import { AppContainer } from 'src/components/appContainer';

const Judge: NextPage = () => {

    const companies = [
        {
            name: 'Tesla',
            status: 'completed',
            imageURI: 'https://images.unsplash.com/photo-1579547621706-1a9c79d5c9f1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80',
        },
        {
            name: 'Facebook',
            status: 'completed',
            imageURI: 'https://images.unsplash.com/photo-1557683311-eac922347aa1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2329&q=80',
        },
        {
            name: 'Apple, Inc.',
            status: 'waiting for judge',
            imageURI: 'https://images.unsplash.com/photo-1557682224-5b8590cd9ec5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2329&q=80',
        },
        {
            name: 'Ford',
            status: 'waiting for judge',
            imageURI: 'https://images.unsplash.com/photo-1557682260-96773eb01377?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2329&q=80',
        },
        {
            name: 'Snap, Inc.',
            status: 'processing',
            imageURI: 'https://images.unsplash.com/photo-1557683316-973673baf926?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2329&q=80',
        },
        {
            name: 'Ethereum Foundation',
            status: 'processing',
            imageURI: 'https://images.unsplash.com/photo-1569982175971-d92b01cf8694?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1335&q=80',
        },
    ]
  return (
    <AppContainer>
        <Flex
            direction={'column'}
            gap={'2em'}
            maxWidth={'960px'}
            width={'100%'}
        >
            { companies.map(company => {
                return (
                    <CompanyStatus 
                        name={company.name}
                        status={company.status}
                        imageURI={company.imageURI}
                    />
                )
            })}
        </Flex>
    </AppContainer>
  )
}


const CompanyStatus: FC<{
    name: any,
    status: any
    imageURI: any
}> = ({
    name,
    status,
    imageURI
}) => {
    return (
        <Flex
            justifyContent={'space-between'}
            alignItems={'center'}
            direction={'row'}
            // backgroundColor={'gray.200'}
            background={'background.lightGray'}
            paddingX={18}
            paddingY={21}
            borderRadius={8}
        >
            {/* COMPANY INFO */}
            <Flex direction={'row'} alignItems={'center'} gap={21}>

                {/* COMPANY IMAGE */}
                <Box borderRadius={999}>
                    <Image
                        src={imageURI}
                        width={'35px'}
                        height={'35px'}
                        borderRadius={999}
                        // borderRadius={100}
                    />
                </Box>

                <Text fontWeight={'bold'} fontSize={'1.15em'}>
                    {name}
                </Text>
            </Flex>

            {/* CURRENT STATUS */}
            <Box border={'1px solid #00000030'} borderRadius={999} paddingX={'16px'} paddingY={'8px'}>
                <Text fontSize={'1em'} fontWeight={'semibold'}>
                    {status}
                </Text>
            </Box>

        </Flex>
    )
}

export default Judge