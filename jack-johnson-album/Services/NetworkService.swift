//
//  NetworkService.swift
//  jack-johnson-album
//
//  Created by Ray Chow on 29/3/2021.
//

import Foundation
import SwiftyJSON
import Alamofire
import RxSwift

// MARK: A generic network service for http request which response JSON
class NetworkService<T: Mappable> {
    // MARK: HTTP GET
    func get(url:String, params:[String:Any]? = nil, requireHeader: Bool = true, encoding: ParameterEncoding = JSONEncoding.default) -> Single<T> {
        return request(url: url, params: params, method: .get, encoding: encoding, requireHeader: requireHeader)
    }
    
    // MARK: An overall function for http request
    private func request(url:String, params:[String:Any]? = nil, method: HTTPMethod = .get, encoding: ParameterEncoding, requireHeader: Bool = true) -> Single<T> {
        let request = NetworkManager.instance.manager.request(url, method: method, parameters: params, encoding: encoding, headers: nil)
        
        return Single<T>.create{ single in
            request.responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let result = T.map(with: json)
                    single(.success(result))
                    break
                case .failure(let error):
                    // Can define different errors before onError
                    single(.failure(error))
                    break
                }
            }
            return Disposables.create{
                request.cancel()
            }
        }
    }
}
