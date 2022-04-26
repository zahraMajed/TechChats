//
//  SwiftEntryClass.swift
//  TechChats
//
//  Created by Zahra Majed on 18/06/1443 AH.
//

import Foundation
import SwiftEntryKit
import UIKit

// MARK: - set attributes functions
final class SwiftEntryClass {
    static var displayMode = EKAttributes.DisplayMode.inferred
    private var displayMode: EKAttributes.DisplayMode {
        return SwiftEntryClass.displayMode
    }
    static func popUpAttributes() -> EKAttributes {
        var attributes: EKAttributes
        attributes = .centerFloat
        attributes.displayMode = displayMode
        attributes.windowLevel = .alerts
        attributes.displayDuration = .infinity
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = .color(color: .dimmedLightBackground)
        attributes.entryBackground = .visualEffect(style: .standard)
        attributes.entranceAnimation = .init(
            scale: .init(
                from: 0.9,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 0.8, initialVelocity: 0)
            ),
            fade: .init(
                from: 0,
                to: 1,
                duration: 0.3
            )
        )
        attributes.exitAnimation = .init(
            scale: .init(
                from: 1,
                to: 0.4,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            fade: .init(
                from: 1,
                to: 0,
                duration: 0.2
            )
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: UIScreen.main.minEdge),
            height: .intrinsic
        )
        return attributes
    }
    
    
}

// MARK: - show viewa functions
extension SwiftEntryClass {
    static func showTryAgainAlertWith(title:String, textDescription:String){
        let attributes = popUpAttributes()
        let title = EKProperty.LabelContent(
            text: title,
            style: .init(
                font: MainFont.medium.with(size: 15),
                color: .black,
                alignment: .center,
                displayMode: displayMode
            )
        )
      
        let description = EKProperty.LabelContent(
            text: textDescription,
            style: .init(
                font: MainFont.light.with(size: 13),
                color: .black,
                alignment: .center,
                displayMode: displayMode
            )
        )
        let image = EKProperty.ImageContent(
            imageName: "alert",
            displayMode: displayMode,
            size: CGSize(width: 25, height: 25),
            contentMode: .scaleAspectFit
        )
        let simpleMessage = EKSimpleMessage(
            image: image,
            title: title,
            description: description
        )
        
        let buttonFont = MainFont.medium.with(size: 16)
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: Color.Teal.a600,
            displayMode: displayMode
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: "TRY AGAIN",
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: Color.Teal.a600.with(alpha: 0.05),
            displayMode: displayMode) {
                SwiftEntryKit.dismiss()
        }
     
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton,
            separatorColor: Color.Gray.light,
            displayMode: displayMode,
            expandAnimatedly: true
        )
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            buttonBarContent: buttonsBarContent
        )
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    static func showOKAlertWith(title:String, textDescription:String){
        let attributes = popUpAttributes()
        let title = EKProperty.LabelContent(
            text: title,
            style: .init(
                font: MainFont.medium.with(size: 15),
                color: .black,
                alignment: .center,
                displayMode: displayMode
            )
        )
      
        let description = EKProperty.LabelContent(
            text: textDescription,
            style: .init(
                font: MainFont.light.with(size: 13),
                color: .black,
                alignment: .center,
                displayMode: displayMode
            )
        )
       
        let simpleMessage = EKSimpleMessage(
            image: nil,
            title: title,
            description: description
        )
        
        let buttonFont = MainFont.medium.with(size: 16)
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: Color.Teal.a600,
            displayMode: displayMode
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: "OK",
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: Color.Teal.a600.with(alpha: 0.05),
            displayMode: displayMode) {
                SwiftEntryKit.dismiss()
        }
     
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton,
            separatorColor: Color.Gray.light,
            displayMode: displayMode,
            expandAnimatedly: true
        )
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            buttonBarContent: buttonsBarContent
        )
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
