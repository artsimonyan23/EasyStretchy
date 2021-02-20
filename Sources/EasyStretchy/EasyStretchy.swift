import UIKit

public final class StretchyHeaderView: UIView {
    public enum UpEffects {
        case minScale(CGFloat) // 0 ..< 1
        case pinned
        case parrallax
        case disable
    }

    public enum DownEffects {
        case strechy
        case maxScale(CGFloat) // 1 <..
        case pinned
        case parrallax
        case disable
    }

    public final var upEffect: UpEffects = .parrallax {
        didSet {
            if case let .minScale(scale) = upEffect, !((0 ..< 1) ~= scale) {
                upEffect = .disable
            }
        }
    }

    public final var downEffect: DownEffects = .strechy {
        didSet {
            if case let .maxScale(scale) = downEffect, scale <= 1 {
                downEffect = .disable
            }
        }
    }

    private var observer: NSKeyValueObservation?
    private weak var header: UIView?

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        guard observer == nil else { return }
        guard let scrollView = findScrollView(of: self) else { return }
        if header == self {
            print("\n🔴 WARNING: Header view can't be an EasyStretchyView\n")
            return
        }
        var topInset = scrollView.contentInset.top
        if #available(iOS 11.0, *) {
            topInset = scrollView.adjustedContentInset.top
        }
        observer = scrollView.observe(\UIScrollView.contentOffset, options: .new) { [weak self] scrollView, _ in
            guard let self = self else { return }
            let y = scrollView.contentOffset.y + topInset
            if scrollView.contentOffset.y < -topInset {
                switch self.downEffect {
                case .strechy:
                    self.header?.clipsToBounds = false
                    self.transform = CGAffineTransform(scaleX: 1 - y / self.bounds.height,
                                                       y: 1 - y / self.bounds.height)
                        .concatenating(CGAffineTransform(translationX: 0,
                                                         y: y / 2))

                case .pinned:
                    self.header?.clipsToBounds = false
                    self.transform = CGAffineTransform(translationX: 0, y: y)

                case .disable:
                    self.header?.clipsToBounds = true
                    self.transform = .identity

                case .parrallax:
                    self.header?.clipsToBounds = false
                    self.transform = CGAffineTransform(translationX: 0, y: y / 2)
                    
                case let .maxScale(scale):
                    self.header?.clipsToBounds = false
                    if self.bounds.height * (scale - 1) > -y {
                        self.transform = CGAffineTransform(scaleX: 1 - y / self.bounds.height,
                                                           y: 1 - y / self.bounds.height)
                            .concatenating(CGAffineTransform(translationX: 0,
                                                             y: y / 2))
                    } else {
                        self.transform = CGAffineTransform(scaleX: scale,
                                                           y: scale)
                            .concatenating(CGAffineTransform(translationX: 0,
                                                             y: -self.bounds.height * (scale - 1) / 2))
                    }
                }
            } else if scrollView.contentOffset.y < self.bounds.height {
                switch self.upEffect {
                case .parrallax:
                    self.header?.clipsToBounds = true
                    self.transform = CGAffineTransform(translationX: 0,
                                                       y: y / 2)

                case let .minScale(scale):
                    self.header?.clipsToBounds = true
                    if self.bounds.height * (1 - scale) > y {
                        self.transform = CGAffineTransform(scaleX: 1 - y / self.bounds.height,
                                                           y: 1 - y / self.bounds.height)
                            .concatenating(CGAffineTransform(translationX: 0,
                                                             y: y / 2))
                    } else {
                        self.transform = CGAffineTransform(scaleX: scale,
                                                           y: scale)
                            .concatenating(CGAffineTransform(translationX: 0,
                                                             y: -self.bounds.height * (scale - 1) / 2))
                    }

                case .pinned:
                    self.header?.clipsToBounds = false
                    self.transform = CGAffineTransform(translationX: 0, y: y)

                case .disable:
                    self.header?.clipsToBounds = true
                    self.transform = .identity
                }
            } else {
                switch self.upEffect {
                case .pinned:
                    self.header?.clipsToBounds = false
                    self.transform = CGAffineTransform(translationX: 0, y: y)

                default:
                    break
                }
            }
        }
    }

    deinit {
        observer?.invalidate()
    }

    private func findScrollView(of view: UIView) -> UIScrollView? {
        if view.superview is UICollectionReusableView || view.superview is UICollectionViewCell || view.superview is UITableViewCell {
            header = view.superview
        }
        if let scrollView = view.superview as? UIScrollView {
            if header == nil {
                header = view
            }
            return scrollView
        } else if let superView = view.superview {
            return findScrollView(of: superView)
        } else {
            return nil
        }
    }
}
