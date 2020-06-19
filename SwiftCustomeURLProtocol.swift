//
//  SwiftCustomeURLProtocol.swift
//  SwiftCutomeProtocol
//
//  Created by mohammed rizwan shaikh on 19/06/20.
//  Copyright © 2020 Mohammed Rizwan SHaikh. All rights reserved.
//

import Foundation

fileprivate var swiftCustomeURLProtocolRequestNumber = 0
var showSwiftCustomeURLProtocolRequestLog = true
var showSwiftCustomeURLProtocolResponseLog = true
var showSwiftCustomeURLProtocolResponseDataLog = true
var checkSwiftCustomeURLProtocolForURLString:String = ""
class SwiftCustomeURLProtocol:URLProtocol,URLSessionDataDelegate,URLSessionTaskDelegate {
    var dataTask:URLSessionTask?
    
    class var CustomKey:String {
        return "CustomURLProtocolHandlerKey"
    }
    override class func canInit(with request: URLRequest) -> Bool {
        
        if URLProtocol.property(forKey: SwiftCustomeURLProtocol.CustomKey, in: request) != nil {
            print("<============================================================================")
            print("SwiftCustomeURLProtocol dublicate request # \(swiftCustomeURLProtocolRequestNumber) #: URL =\(request.url?.absoluteString ??  ""), \n\n Header=\(request.allHTTPHeaderFields ?? [:]) \n\n httpBody=\(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
            print("============================================================================>")
            return false
        }
        if request.url?.absoluteString.contains(checkSwiftCustomeURLProtocolForURLString) ?? false {
            return true
        }
        return false
    }
 
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
      
    override func startLoading() {

        if let mutableRequest = self.request as? NSMutableURLRequest {
            URLProtocol.setProperty(true, forKey: SwiftCustomeURLProtocol.CustomKey, in: mutableRequest)
        }
        swiftCustomeURLProtocolRequestNumber += 1
        if showSwiftCustomeURLProtocolRequestLog {
            print("<============================================================================")
            print("SwiftCustomeURLProtocol request # \(swiftCustomeURLProtocolRequestNumber) #: URL =\(request.url?.absoluteString ??  ""), \n\n Header=\(request.allHTTPHeaderFields ?? [:]) \n\n httpBody=\(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
            print("============================================================================>")
        }
        let defaultConfigObj = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)
        defaultSession.sessionDescription = "\(swiftCustomeURLProtocolRequestNumber)"
        self.dataTask = defaultSession.dataTask(with: self.request)
        self.dataTask?.resume()

    }
    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if showSwiftCustomeURLProtocolResponseLog {
            print("<============================================================================")
            print("SwiftCustomeURLProtocol urlResponse for request # \(session.sessionDescription ?? "") # = \(response)")
            print("============================================================================>")
        }
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if showSwiftCustomeURLProtocolResponseDataLog {
            print("<============================================================================")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("SwiftCustomeURLProtocol urlJsonData for request # \(session.sessionDescription ?? "") # = \(json)")
                   }
            }catch {
                print("SwiftCustomeURLProtocol urlJsonData for request # \(session.sessionDescription ?? "") Invalid json object")
                print("SwiftCustomeURLProtocol urlStringData for request # \(session.sessionDescription ?? "") = \(String(data: data, encoding: .utf8) ?? "")")
            }
            print("============================================================================>")
        }
        
        self.client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    
        if error == nil {
            self.client?.urlProtocolDidFinishLoading(self)
        }else {
            print("<============================================================================")
            print("SwiftCustomeURLProtocol urlError for request # \(session.sessionDescription ?? "") # = \(error!)")
            print("============================================================================>")
            self.client?.urlProtocol(self, didFailWithError: error!)
        }
        
    }
}
