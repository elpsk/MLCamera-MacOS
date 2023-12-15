//
//  ContentView.swift
//  MLCameraMac
//
//  Created by Alberto Pasca on 15/12/23.
//

import SwiftUI

struct ContentView: View {

    @State private var selectedImage: NSImage?
    @State private var imageURL: URL?

    @State private var scanResults: [String] = []
    private var identifier = LegoIdentifier()

    var body: some View {
        VStack {
            HStack {
                InputImageView(image: self.$selectedImage)

                HStack {
                    VStack(alignment: .leading, content: {
                        Text(scanResults.joined(separator: "\n"))
                        Spacer()
                    })
                    Spacer()
                }
                .frame(width: 320)
                .padding()

                Spacer()
            }
            .onChange(of: selectedImage, { oldValue, newValue in
                if let image = newValue, let imageData = image.tiffRepresentation(using: .none, factor: 0) {
                    identifier.identifyPiece(using: imageData) { results, error in
                        scanResults = results ?? ["NO DATA"]
                        print( scanResults )
                    }
                }
            })
            Spacer()
        }
        .padding()
    }

}

#Preview {
    ContentView()
}



struct InputImageView: View {
    
    @Binding var image: NSImage?
    
    var body: some View {
        ZStack {
            if self.image != nil {
                Image(nsImage: self.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Drag and drop image file")
                    .frame(width: 320)
            }
        }
        .frame(height: 320)
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
        .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) -> Bool in
            if let item = items.first {
                if let identifier = item.registeredTypeIdentifiers.first {
                    print("onDrop with identifier = \(identifier)")
                    if identifier == "public.url" || identifier == "public.file-url" {
                        item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
                            DispatchQueue.main.async {
                                if let urlData = urlData as? Data {
                                    let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                                    if let img = NSImage(contentsOf: urll) {
                                        self.image = img
                                        print("got it")
                                    }
                                }
                            }
                        }
                    }
                }
                return true
            } else {
                print("item not here")
                return false
            }
        }
    }
}
