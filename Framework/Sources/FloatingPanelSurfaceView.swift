//
//  Created by Shin Yamamoto on 2018/09/26.
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

import UIKit

class FloatingPanelSurfaceContentView: UIView {}

/// A view that presents a surface interface in a floating panel.
public class FloatingPanelSurfaceView: UIView {
    
    /// A GrabberHandleView object displayed at the top of the surface view
    public var grabberHandle: GrabberHandleView!
    
    /// The height of the grabber bar area
    public static var topGrabberBarHeight: CGFloat {
        return Default.grabberTopPadding * 2 + GrabberHandleView.Default.height // 17.0
    }
    
    /// A UIView object that can have the surface view added to it.
    public var contentView: UIView!
    
    private var color: UIColor? = .white { didSet { setNeedsLayout() } }
    private var bottomOverflow: CGFloat = 0.0 // Must not call setNeedsLayout()
    
    public override var backgroundColor: UIColor? {
        get { return color }
        set { color = newValue }
    }
    
    /// The radius to use when drawing top rounded corners.
    ///
    /// `self.contentView` is masked with the top rounded corners automatically on iOS 11 and later.
    /// On iOS 10, they are not automatically masked because of a UIVisualEffectView issue. See https://forums.developer.apple.com/thread/50854
    public var cornerRadius: CGFloat = 0.0 { didSet { setNeedsLayout() } }
    
    /// A Boolean indicating whether the surface shadow is displayed.
    public var shadowHidden: Bool = false  { didSet { setNeedsLayout() } }
    
    /// The color of the surface shadow.
    public var shadowColor: UIColor = .black  { didSet { setNeedsLayout() } }
    
    /// The offset (in points) of the surface shadow.
    public var shadowOffset: CGSize = CGSize(width: 0.0, height: 1.0)  { didSet { setNeedsLayout() } }
    
    /// The opacity of the surface shadow.
    public var shadowOpacity: Float = 0.2 { didSet { setNeedsLayout() } }
    
    /// The blur radius (in points) used to render the surface shadow.
    public var shadowRadius: CGFloat = 3  { didSet { setNeedsLayout() } }
    
    /// The width of the surface border.
    public var borderColor: UIColor?  { didSet { setNeedsLayout() } }
    
    /// The color of the surface border.
    public var borderWidth: CGFloat = 0.0  { didSet { setNeedsLayout() } }
    
    private var shadowLayer: CAShapeLayer!  { didSet { setNeedsLayout() } }
    
    let estTimeContianerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 248/255, alpha: 1)
        return view
    }()
    
    let estTimeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.borderColor = UIColor(red: 76/255, green: 187/255, blue: 255/255, alpha: 1).cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    public lazy var lblEstMin: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Barlow-Regular", size: 32)
        label.textColor = UIColor(red: 8/255, green: 12/255, blue: 78/255, alpha: 1)
        label.textAlignment = .center
        label.text = "1-5"
        return label
    }()
    
    lazy var lblMin: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Barlow-Medium", size: 12)
        label.textColor = UIColor(red: 8/255, green: 12/255, blue: 78/255, alpha: 1)
        label.textAlignment = .center
        label.text = "MIN"
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    public var isEstTimeViewEnable = true {
        didSet {
            estTimeContianerView.isHidden = !isEstTimeViewEnable
        }
    }
    
    private struct Default {
        public static let grabberTopPadding: CGFloat = 6.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    private func render() {
        super.backgroundColor = .clear
        self.clipsToBounds = false
        
        let shadowLayer = CAShapeLayer()
        layer.insertSublayer(shadowLayer, at: 0)
        self.shadowLayer = shadowLayer
        
        let contentView = FloatingPanelSurfaceContentView()
        addSubview(contentView)
        self.contentView = contentView as UIView
        contentView.backgroundColor = color
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
            ])
        
        setupEstTimeView()
        
        let grabberHandle = GrabberHandleView()
        addSubview(grabberHandle)
        self.grabberHandle = grabberHandle
        
        grabberHandle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabberHandle.topAnchor.constraint(equalTo: topAnchor, constant: Default.grabberTopPadding),
            grabberHandle.widthAnchor.constraint(equalToConstant: grabberHandle.frame.width),
            grabberHandle.heightAnchor.constraint(equalToConstant: grabberHandle.frame.height),
            grabberHandle.centerXAnchor.constraint(equalTo: centerXAnchor),
            ])
    }
    
    private func setupEstTimeView() {
        addSubview(estTimeContianerView)
        
        NSLayoutConstraint.activate([
            estTimeContianerView.widthAnchor.constraint(equalToConstant: 80),
            estTimeContianerView.heightAnchor.constraint(equalToConstant: 80),
            estTimeContianerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            estTimeContianerView.centerYAnchor.constraint(equalTo: topAnchor)
            ])
        
        
        estTimeContianerView.addSubview(estTimeView)
        NSLayoutConstraint.activate([
            estTimeView.rightAnchor.constraint(equalTo: estTimeContianerView.rightAnchor, constant: -5),
            estTimeView.leftAnchor.constraint(equalTo: estTimeContianerView.leftAnchor, constant: 5),
            estTimeView.topAnchor.constraint(equalTo: estTimeContianerView.topAnchor, constant: 5),
            estTimeView.bottomAnchor.constraint(equalTo: estTimeContianerView.bottomAnchor, constant: -5)
            ])
        
        estTimeView.addSubview(lblEstMin)
        estTimeView.addSubview(lblMin)
        
        NSLayoutConstraint.activate([
            lblEstMin.rightAnchor.constraint(equalTo: estTimeView.rightAnchor, constant: -1),
            lblEstMin.leftAnchor.constraint(equalTo: estTimeView.leftAnchor, constant: 1),
            lblEstMin.topAnchor.constraint(equalTo: estTimeView.topAnchor, constant: 8)
            ])
        
            NSLayoutConstraint.activate([
                lblMin.centerXAnchor.constraint(equalTo: estTimeView.centerXAnchor),
                lblMin.bottomAnchor.constraint(equalTo: estTimeView.bottomAnchor, constant: -6)
                ])
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateShadowLayer()
        updateContentViewMask()
        
        contentView.layer.borderColor = borderColor?.cgColor
        contentView.layer.borderWidth = borderWidth
        contentView.backgroundColor = color
        
        estTimeContianerView.layer.cornerRadius = 40
        estTimeView.layer.cornerRadius = estTimeView.frame.height / 2
        
    }
    
    private func updateShadowLayer() {
        log.debug("SurfaceView bounds", bounds)
        
        var rect = bounds
        rect.size.height += bottomOverflow // Expand the height for overflow buffer
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        shadowLayer.path = path.cgPath
        shadowLayer.fillColor = color?.cgColor
        if shadowHidden == false {
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowOffset = shadowOffset
            shadowLayer.shadowOpacity = shadowOpacity
            shadowLayer.shadowRadius = shadowRadius
        }
    }
    
    private func updateContentViewMask() {
        if #available(iOS 11, *) {
            // Don't use `contentView.clipToBounds` because it prevents content view from expanding the height of a subview of it
            // for the bottom overflow like Auto Layout settings of UIVisualEffectView in Main.storyborad of Example/Maps.
            // Because the bottom of contentView must be fit to the bottom of a screen to work the `safeLayoutGuide` of a content VC.
            let maskLayer = CAShapeLayer()
            var rect = bounds
            rect.size.height += bottomOverflow
            let path = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            maskLayer.path = path.cgPath
            contentView.layer.mask = maskLayer
        } else {
            // Don't use `contentView.layer.mask` because of a UIVisualEffectView issue in iOS 10, https://forums.developer.apple.com/thread/50854
            // Instead, a user can mask the content view manually in an application.
        }
    }
    
    func set(bottomOverflow: CGFloat) {
        self.bottomOverflow = bottomOverflow
        updateShadowLayer()
        updateContentViewMask()
    }
    
    
    func add(childView: UIView) {
        contentView.addSubview(childView)
        childView.frame = contentView.bounds
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            childView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0),
            childView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0),
            childView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0),
            ])
    }
}
