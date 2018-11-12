//
//  GraphQLExample.swift
//  FoundSounds
//
//  Created by David Jensenius on 2018-11-11.
//  Copyright © 2018 David Jensenius. All rights reserved.
//

import Foundation
import Apollo

class GraphQLExample {
    func getExampleQuery(
        networkTransport: NetworkTransport = HTTPNetworkTransport(
            url: URL(string: "https://645547e3.ngrok.io/graphql")!
        ),
        closure: @escaping (_ sound: ExampleQuery.Data) -> Void) {

        let apollo = ApolloClient(networkTransport: networkTransport)

        apollo.fetch(query: ExampleQuery()) { (result, error) in
            guard let data = result?.data else {
                print("Could not assign data")
                if error != nil {
                    print(error!)
                }
                return
            }
            closure(data)
        }
    }
}
