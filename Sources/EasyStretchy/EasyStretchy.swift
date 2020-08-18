import UIKit

final class StretchyHeaderView: UIView {

    enum UpEffects {
        case parrallax
        case disable
    }

    enum DownEffects {
        case strechy
        case frozen
        case center
        case disable
    }

    var upEffect: UpEffects = .parrallax
    var downEffect: DownEffects = .strechy

    private var observer: NSKeyValueObservation?

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        observer?.invalidate()
        observer = findScrollView(of: self)?.observe(\UIScrollView.contentOffset, options: .new) { [weak self] scrollView, _ in
            guard let self = self else { return }
            if scrollView.contentOffset.y < 0 {
                switch self.downEffect {
                case .strechy:
                    self.transform = CGAffineTransform(scaleX: 1 - scrollView.contentOffset.y / self.bounds.height, y: 1 - scrollView.contentOffset.y / self.bounds.height)
                        .concatenating(CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y / 2))

                case .frozen:
                    self.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)

                case .center:
                    self.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y / 2)

                case .disable:
                    break
                }
            } else if scrollView.contentOffset.y < self.bounds.height {
                switch self.upEffect {
                case .parrallax:
                    self.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y / 2)

                case .disable:
                    break
                }
            }
        }
    }

    deinit {
        observer?.invalidate()
    }

    private func findScrollView(of view: UIView) -> UIScrollView? {
        if downEffect == .strechy, view.superview is UICollectionReusableView {
            view.superview?.clipsToBounds = false
        }
        if let scrollView = view.superview as? UIScrollView {
            return scrollView
        } else if let superView = view.superview {
            return findScrollView(of: superView)
        } else {
            return nil
        }
    }

}
