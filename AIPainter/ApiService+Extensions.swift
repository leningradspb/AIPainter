//
//  ApiService+Extensions.swift
//  AIPainter
//
//  Created by Eduard Kanevskii on 09.02.2024.
//

import Foundation

class APIService {
    // TODO: В реальном проекте здесь может быть универсальный API метод
}

extension APIService {
    static func requestPhotoBy(filter: StableDiffusionFilterRequest, completion: @escaping (_ paymentHistory: StableDiffusionResponse?, _ error: Error?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://stablediffusionapi.com/api/v3/dreambooth")!)
        request.configure(.post)
        
        do {
            let data = try JSONEncoder().encode(filter)
            request.httpBody = data
            print(data)
            print(String(data: data, encoding: .utf8) as Any)
        } catch {
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("---------------------------------")
            print("Server response:")
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("DATA NOT FOUND!!! 🤯")
                completion(nil, error)
                return
            }
            print(String(data: data, encoding: .utf8) as Any)
//            print("JSON String: \(String(data: data, encoding: .utf8))")
            do {
                let history = try JSONDecoder().decode(StableDiffusionResponse.self, from: data)
                print(history as Any)
                completion(history, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}


struct StableDiffusionResponse: Codable {
    let status: String?
    let output: [String]?
}

struct StableDiffusionFilterRequest: Codable {
    let key: String
    let prompt: String
    let negative_prompt: String?
    var model_id: String = "midjourney"
    let guidance_scale: Int = 8
    let num_inference_steps: Int = 25
    let width: Int = 512
    let height: Int = 512
    let samples: Int = 1
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension URLRequest {
    mutating func configure(
        _ method: HttpMethod,
        _ parameters: [String: Any?]? = nil
    ) {
        self.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.httpMethod = method.rawValue
        if let strongParameters = parameters, !strongParameters.isEmpty {
            self.httpBody = try? JSONSerialization.data(withJSONObject: strongParameters)
        }
    }
}
enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

