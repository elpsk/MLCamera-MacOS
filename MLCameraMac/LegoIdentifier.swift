//
//  LegoIdentifier.swift
//  MLCamera
//
//  Created by Alberto Pasca on 04/12/23.
//

import Cocoa
import CoreML
import Vision

class LegoIdentifier {

    private(set) var model: VNCoreMLModel?

    init() {
        //
        // Cambia MyImageClassifier con il tuo modello creato.
        //
        // Questo è un ImageClassifier semplice.
        // Se scegli un altro modello devi cambiare la funzione identifyPiece()
        //
        // Aprendo il file MyImageClassifier con XCode puoi anche usare la preview per giocare con il tuo modello.
        //
        model = try? VNCoreMLModel(for: MyImageClassifier(configuration: MLModelConfiguration()).model)
    }

    func identifyPiece( using data: Data, limit: Int = 10, completion: @escaping (_ results: [String]?, _ error: Error?) -> Void ) {
        var legoResults = [String]()

        //
        // CoreML request
        //
        let request = VNCoreMLRequest(model: model!) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                completion(nil, NSError(domain: "No data found.", code: 0))
                return
            }

            //
            // debug stuffs
            //
            results.forEach { classificationObservation in
                print( classificationObservation )
            }

            //
            // prepara i nomi dei pezzi
            //
            let pieces = results.map({ $0.identifier }).prefix(limit) // dammi i primi "limit", default = 10
            legoResults.append(contentsOf: Array(pieces))

            completion(legoResults, nil)
        }

        guard let ciImage = CIImage(data: data) else { fatalError("Errore durante la conversione dell'immagine.") }
        let handler = VNImageRequestHandler(ciImage: ciImage)

        do {
            //
            // esegue la request di CoreML
            //
            try handler.perform([
                request
            ])
        } catch {}
    }

}
