import SwiftUI
import PhotosUI

struct ProductFarmerView: View {
    let product: FarmProduct
    let onChange: (FarmProduct) -> Void

    var body: some View {
        HStack {
           
            if let urlString = product.image_url, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
            }
            
            Text(product.name)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            Spacer()
            
        }
        .padding()
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

