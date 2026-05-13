// SPDX-License-Identifier: GPL-2.0-only
import AppKit

enum StatusItemPersistence {
    enum OwnedItem: CaseIterable {
        case main
        case hiddenBarSeparator

        var autosaveName: String {
            switch self {
            case .main:
                "omniwm_main"
            case .hiddenBarSeparator:
                "omniwm_hiddenbar_separator"
            }
        }
    }

    @MainActor
    static func configureMandatoryItem(
        _ statusItem: NSStatusItem,
        as ownedItem: OwnedItem
    ) {
        statusItem.autosaveName = ownedItem.autosaveName
        // These owned items are required recovery surfaces; do not allow AppKit
        // drag-removal state to persist them as hidden on the next launch.
        statusItem.behavior = []
        statusItem.isVisible = true
    }
}
