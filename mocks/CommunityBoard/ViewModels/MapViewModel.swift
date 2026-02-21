import SwiftUI
import MapKit

@MainActor
final class MapViewModel: ObservableObject {
    // MARK: - Map State
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )

    // MARK: - Posts
    @Published var posts: [Post] = []
    @Published var comments: [Comment] = []
    @Published var currentUser: CommunityUser

    // MARK: - UI State
    @Published var selectedPost: Post?
    @Published var showingCreatePost = false
    @Published var showingPostDetail = false
    @Published var showingFilterPanel = false
    @Published var showingPostList = false
    @Published var showingProfile = false

    // MARK: - Filter State
    @Published var selectedCategories: Set<PostCategory> = Set(PostCategory.allCases)
    @Published var showResolvedPosts = true
    @Published var searchText = ""
    @Published var sortOrder: SortOrder = .newest

    // MARK: - New Post State
    @Published var newPostCoordinate: CLLocationCoordinate2D?

    enum SortOrder: String, CaseIterable {
        case newest = "新しい順"
        case popular = "人気順"
        case nearest = "近い順"
    }

    // MARK: - Computed Properties

    var filteredPosts: [Post] {
        var result = posts.filter { post in
            selectedCategories.contains(post.category) &&
            (showResolvedPosts || !post.isResolved) &&
            !post.isExpired
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { post in
                post.title.lowercased().contains(query) ||
                post.body.lowercased().contains(query) ||
                post.tags.contains(where: { $0.lowercased().contains(query) })
            }
        }

        switch sortOrder {
        case .newest:
            result.sort { $0.createdAt > $1.createdAt }
        case .popular:
            result.sort { $0.likeCount > $1.likeCount }
        case .nearest:
            break
        }

        return result
    }

    var postsByCategory: [(PostCategory, Int)] {
        PostCategory.allCases.map { category in
            (category, posts.filter { $0.category == category && !$0.isExpired }.count)
        }.filter { $0.1 > 0 }
    }

    var totalActivePosts: Int {
        posts.filter { !$0.isExpired }.count
    }

    // MARK: - Init

    init() {
        self.currentUser = CommunityUser(
            name: "あなた",
            avatarEmoji: "🙂",
            bio: "コミュニティの新しいメンバー",
            postCount: 0,
            helpCount: 0,
            reputation: 5
        )
        loadSampleData()
    }

    // MARK: - Actions

    func createPost(title: String, body: String, category: PostCategory, tags: [String], coordinate: CLLocationCoordinate2D) {
        let post = Post(
            title: title,
            body: body,
            category: category,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            authorId: currentUser.id,
            authorName: currentUser.name,
            authorEmoji: currentUser.avatarEmoji,
            tags: tags
        )
        posts.insert(post, at: 0)
        currentUser.postCount += 1
        currentUser.reputation += 2
        newPostCoordinate = nil
    }

    func likePost(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].likeCount += 1
    }

    func resolvePost(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isResolved = true
        if post.category == .help || post.category == .lostFound {
            currentUser.helpCount += 1
            currentUser.reputation += 5
        }
    }

    func addComment(to post: Post, body: String) {
        let comment = Comment(
            postId: post.id,
            authorId: currentUser.id,
            authorName: currentUser.name,
            authorEmoji: currentUser.avatarEmoji,
            body: body
        )
        comments.append(comment)
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].commentCount += 1
        }
        currentUser.reputation += 1
    }

    func commentsForPost(_ post: Post) -> [Comment] {
        comments.filter { $0.postId == post.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func deletePost(_ post: Post) {
        posts.removeAll { $0.id == post.id }
        comments.removeAll { $0.postId == post.id }
    }

    func moveToPost(_ post: Post) {
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: post.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            )
        }
        selectedPost = post
        showingPostDetail = true
    }

    func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        newPostCoordinate = coordinate
        showingCreatePost = true
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        let (samplePosts, sampleComments) = SampleData.generate()
        self.posts = samplePosts
        self.comments = sampleComments
    }
}
