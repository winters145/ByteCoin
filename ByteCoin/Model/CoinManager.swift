//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "B0FCBCF9-566B-4AD0-AA6A-4E048D20FFC6"
    
    var delegate: CoinManagerDelegate?
        
    func getCoinPrice(for currency: String) {
        
        //Use String concatenation to add the selected currency at the end of the baseURL along with the API key.
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        //Use optional binding to unwrap the URL that's created from the urlString
        if let url = URL(string: urlString) {
            
            //Create a new URLSession object with default configuration.
            let session = URLSession(configuration: .default)
            
            //Create a new data task for the URLSession
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                //Format the data we got back as a string to be able to print it.
                    //let dataAsString = String(data: data!, encoding: .utf8)
                if let safeData = data {
                    
                    if let bitcoinPrice = parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
        
    }
    func parseJSON(_ data: Data) -> Double? {
        
        // Create a JSON decoder
        let decoder = JSONDecoder()
        do {
            
            // try to decode the data using the CoinData struct
            let decodedData = try decoder.decode(CoinData.self, from: data)
            
            // get the last property from the decoded data
            let lastPrice = decodedData.rate
            
            print(lastPrice)
            return lastPrice
            
        } catch {
            
            // catch any errors
            print(error)
            return nil
        }
    }
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

}
