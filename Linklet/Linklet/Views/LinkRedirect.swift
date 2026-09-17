//
//  LinkRedirect.swift
//  Linklet
//
//  Created by Chef on 8/18/26.
//

internal import Combine
import CoreGraphics
import ImageIO
import LinkPresentation
import SwiftUI
internal import UniformTypeIdentifiers

func loadImageData(from provider: NSItemProvider) async -> Data? {
    await withCheckedContinuation { continuation in
        _ = provider.loadDataRepresentation(for: .image) { data, error in
            continuation.resume(returning: data)
        }
    }
}

func loadCGImage(from metadata: LPLinkMetadata) async -> CGImage? {
    guard let provider = metadata.imageProvider else { return nil }
    guard let data = await loadImageData(from: provider) else { return nil }

    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
        let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
        return nil
    }
    return cgImage
}

enum DomainCard: Int16, Codable {
    case exact
    case hostname  // fully qualified domain name
    case domain  // apex domain
    case wildcard
}

struct LinkRedirectWizardTitleField: View {
    @State var vm: RedirectWizardManager

    @FocusState private var titleFieldIsFocused: Bool
    @State private var isHoveringTextField = false

    var body: some View {
        TextField("Title", text: $vm.title)
            .textFieldStyle(.plain)
            .truncationMode(.tail)
            .redacted(reason: vm.title.isEmpty ? .placeholder : [])
            .font(.system(size: 15, weight: .medium))
            .frame(width: 200, alignment: .leading)  // arbitrary width chosen to prevent sudden popping on resolve
            .focused($titleFieldIsFocused)
            .help(vm.title)
            // TODO: the UX here isn't perfect. Maybe unfocus based on other elements. For now this is sufficent.
            .onHover { hovering in
                isHoveringTextField = hovering
            }
            .onChange(of: vm.title, debounce: .seconds(1.5)) { old, new in
                if isHoveringTextField == false {
                    titleFieldIsFocused = false
                }
            }
    }
}

struct LinkRedirectWizard: View {
    @State var vm: RedirectWizardManager

    var body: some View {
        @Bindable var browserService = vm.redirectManager.browserService

        VStack {
            HStack(alignment: .top) {
                if let favicon = vm.favicon {
                    Image(favicon, scale: 1, label: Text("Preview"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "link")
                        .font(.system(size: 16))
                        .scaledToFit()
                        .foregroundStyle(.primary)
                        .redacted(reason: .placeholder)  // TODO: unredact if fail to retrieve icon
                        .background(
                            .quaternary,
                            in: RoundedRectangle(
                                cornerRadius: 7,
                                style: .continuous
                            )
                        )
                        .frame(width: 32, height: 32)
                        .task {
                            do {
                                let provider = LPMetadataProvider()
                                provider.timeout = 10  // default 30
                                let metadata =
                                    try await provider.startFetchingMetadata(
                                        for: vm.url
                                    )
                                if let newTitle = metadata.title {
                                    vm.title = newTitle
                                }
                                vm.favicon = await loadCGImage(from: metadata)
                            } catch {
                                print("FAILED! \(error)")
                            }
                        }
                }

                VStack(alignment: .leading, spacing: 2) {
                    LinkRedirectWizardTitleField(vm: vm)

                    Text(vm.url.absoluteString)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Form {
                    Picker("Browser", selection: $vm.selectedBrowser) {
                        ForEach($browserService.browsers, id: \.self) {
                            browser in
                            Text(browser.wrappedValue.name).tag(
                                browser.wrappedValue.id
                            )
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Profile", selection: $vm.selectedProfile) {
                        ForEach($vm.selectedBrowser.profiles, id: \.self) {
                            profile in
                            Text(profile.wrappedValue.name).tag(
                                profile.wrappedValue.id
                            )
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            HStack(alignment: .bottom) {
                Picker("Match", selection: $vm.matchchoice) {
                    Text("Exact").tag(DomainCard.exact)
                    Text("Domain (\(vm.url.host() ?? "unknown"))").tag(
                        DomainCard.domain
                    )
                    // TODO: implement all match types
                    Text("Hostname").strikethrough().tag(DomainCard.hostname) // TODO: difficult due to TLDs domains like co.uk
                    Text("Wildcard").strikethrough().tag(DomainCard.wildcard)
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()

                Spacer()

                Button(action: vm.open) {
                    Text("Open")
                }.disabled(vm.isInvalidBookmark)

                Button(action: vm.saveAndOpen) {
                    Text("Save & Open")
                }.disabled(vm.isInvalidBookmark)
            }
        }
    }
}

struct LinkRedirectWindow: View {
    @State var vm: RedirectManager

    var noLinksToRedirect: some View {
        Text("This window should not be open; no links to redirect")  // TODO: add a better message for this case
    }

    var body: some View {
        if let wizardVm = vm.currentRedirectWizard {
            LinkRedirectWizard(vm: wizardVm)
//            EmptyView()
        } else {
            noLinksToRedirect
        }
    }
}
