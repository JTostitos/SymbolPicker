//
//  SymbolPicker.swift
//  SymbolPicker
//
//  Created by Yubo Qin on 2/14/22.
//

import SwiftUI

#if os(macOS)
import AppKit
typealias PlatformColor = NSColor
#else
import UIKit
typealias PlatformColor = UIColor
#endif

public struct SymbolPicker: View {

    // MARK: - Static consts
    
    private static let symbols15: [String] = {
        guard let path = Bundle.module.path(forResource: "sfsymbols15", ofType: "txt"),
              let content = try? String(contentsOfFile: path)
        else {
            return []
        }
        return content
            .split(separator: "\n")
            .map { String($0) }
    }()
    
    private static let symbols16: [String] = {
        guard let path = Bundle.module.path(forResource: "sfsymbols16", ofType: "txt"),
              let content = try? String(contentsOfFile: path)
        else {
            return []
        }
        return content
            .split(separator: "\n")
            .map { String($0) }
    }()

    private static var gridDimension: CGFloat {
        #if os(iOS)
            return 64
        #elseif os(tvOS)
            return 128
        #elseif os(macOS)
            return 30
        #else
            return 48
        #endif
    }

    private static var symbolSize: CGFloat {
        #if os(iOS)
            return 24
        #elseif os(tvOS)
            return 48
        #elseif os(macOS)
            return 14
        #else
            return 24
        #endif
    }

    private static var symbolCornerRadius: CGFloat {
        #if os(iOS)
            return 8
        #elseif os(tvOS)
            return 12
        #elseif os(macOS)
            return 4
        #else
            return 8
        #endif
    }

    // MARK: - Properties

    @Binding public var symbol: String
    @State private var searchText = ""
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Public Init

    public init(symbol: Binding<String>) {
        _symbol = symbol
    }

    // MARK: - View Components

    @ViewBuilder
    private var searchableSymbolGrid: some View {
        #if os(iOS)
        symbolGrid
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        #elseif os(tvOS)
            symbolGrid
                .searchable(text: $searchText, placement: .automatic)
        #elseif os(macOS)
            VStack(spacing: 10) {
//                TextField(LocalizedString("search_placeholder"), text: $searchText)
//                    .disableAutocorrection(true)
                symbolGrid
                    .searchable(text: $searchText, placement: .toolbar)
            }
        #else
        symbolGrid
            .searchable(text: $searchText, placement: .automatic)
        #endif
    }

    private var symbolGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Self.gridDimension, maximum: Self.gridDimension))]) {
                ForEach(Self.symbols15.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { thisSymbol in
                LazyVStack {
                        Button(action: {
                            symbol = thisSymbol
                            
                            // Dismiss sheet. macOS will have done button
#if !os(macOS)
                            presentationMode.wrappedValue.dismiss()
#endif
                        }) {
                            if thisSymbol == symbol {
                                Image(systemName: thisSymbol)
                                    .font(.system(size: Self.symbolSize))
                                    .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
#if !os(tvOS)
                                    .background(Color.accentColor)
#else
                                    .background(Color.gray.opacity(0.3))
#endif
                                    .cornerRadius(Self.symbolCornerRadius)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: thisSymbol)
                                    .font(.system(size: Self.symbolSize))
                                    .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
//                                    .background(Self.systemBackground)
                                #if os(iOS)
                                    .background(Color(uiColor: .secondarySystemFill))
                                #endif
                                    .cornerRadius(Self.symbolCornerRadius)
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    public var body: some View {
        #if !os(macOS)
            NavigationView {
                searchableSymbolGrid
                    #if os(iOS)
                    .navigationTitle("Symbols")
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.title2)
                                .hoverEffect(.lift)
                                .onTapGesture {
                                    presentationMode.wrappedValue.dismiss()
                                }
                        }
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        #else
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedString("sf_symbol_picker"))
                    .font(.headline)
                Divider()
                searchableSymbolGrid
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                HStack {
                    Button {
                        symbol = ""
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(LocalizedString("cancel"))
                    }
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(LocalizedString("done"))
                    }
                }
            }
            .padding()
            .frame(width: 520, height: 300, alignment: .center)
        #endif
    }
}

private func LocalizedString(_ key: String) -> String {
    NSLocalizedString(key, bundle: .module, comment: "")
}

struct SymbolPicker_Previews: PreviewProvider {
    @State static var symbol: String = "square.and.arrow.up"

    static var previews: some View {
        Group {
            SymbolPicker(symbol: Self.$symbol)
            SymbolPicker(symbol: Self.$symbol)
                .preferredColorScheme(.dark)
        }
    }
}
