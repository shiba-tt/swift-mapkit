import Foundation

/// デモ用サンプルデータ
enum SampleData {
    static func generate() -> ([Post], [Comment]) {
        let users = sampleUsers()
        let posts = samplePosts(users: users)
        let comments = sampleComments(posts: posts, users: users)
        return (posts, comments)
    }

    private static func sampleUsers() -> [CommunityUser] {
        [
            CommunityUser(name: "田中太郎", avatarEmoji: "👨", bio: "東京駅周辺に住んで10年", postCount: 15, helpCount: 8, reputation: 120),
            CommunityUser(name: "鈴木花子", avatarEmoji: "👩", bio: "地域のイベント大好き！", postCount: 22, helpCount: 12, reputation: 180),
            CommunityUser(name: "佐藤健一", avatarEmoji: "🧑", bio: "散歩が趣味です", postCount: 8, helpCount: 3, reputation: 45),
            CommunityUser(name: "山田美咲", avatarEmoji: "👧", bio: "グルメ巡りが大好き", postCount: 30, helpCount: 5, reputation: 95),
            CommunityUser(name: "高橋誠", avatarEmoji: "👴", bio: "町内会長やってます", postCount: 45, helpCount: 20, reputation: 250),
            CommunityUser(name: "渡辺あかり", avatarEmoji: "👶", bio: "子育て中のママです", postCount: 12, helpCount: 6, reputation: 60),
        ]
    }

    private static func samplePosts(users: [CommunityUser]) -> [Post] {
        let calendar = Calendar.current

        return [
            // 情報共有
            Post(
                title: "丸の内仲通りで工事が始まります",
                body: "来週月曜から丸の内仲通りの歩道が一部通行止めになるそうです。迂回路を使ってください。工事は約2週間の予定です。",
                category: .info,
                latitude: 35.6815,
                longitude: 139.7640,
                authorId: users[0].id,
                authorName: users[0].name,
                authorEmoji: users[0].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -2, to: Date())!,
                likeCount: 12,
                commentCount: 3,
                tags: ["工事", "通行止め", "丸の内"]
            ),
            Post(
                title: "東京駅八重洲口に新しいバス停設置",
                body: "東京駅八重洲口に高速バスの新しい乗り場ができました。以前の場所と変わっているので注意してください。",
                category: .info,
                latitude: 35.6800,
                longitude: 139.7700,
                authorId: users[4].id,
                authorName: users[4].name,
                authorEmoji: users[4].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -5, to: Date())!,
                likeCount: 25,
                commentCount: 5,
                tags: ["バス", "東京駅", "交通"]
            ),

            // 助け合い
            Post(
                title: "引っ越しの手伝いを探しています",
                body: "来週の土曜日に日本橋へ引っ越し予定です。段ボール箱の運搬を手伝ってくれる方を探しています。お礼にお昼ご飯をごちそうします！",
                category: .help,
                latitude: 35.6839,
                longitude: 139.7745,
                authorId: users[2].id,
                authorName: users[2].name,
                authorEmoji: users[2].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -8, to: Date())!,
                likeCount: 5,
                commentCount: 2,
                tags: ["引っ越し", "手伝い", "日本橋"]
            ),
            Post(
                title: "高齢者の買い物代行ボランティア募集",
                body: "近所にお住まいの高齢者の方の買い物代行ボランティアを募集しています。週に1回程度、スーパーまでの買い物をお手伝いいただける方、ぜひご連絡ください。",
                category: .help,
                latitude: 35.6780,
                longitude: 139.7650,
                authorId: users[4].id,
                authorName: users[4].name,
                authorEmoji: users[4].avatarEmoji,
                createdAt: calendar.date(byAdding: .day, value: -1, to: Date())!,
                likeCount: 18,
                commentCount: 4,
                tags: ["ボランティア", "高齢者", "買い物"]
            ),

            // イベント
            Post(
                title: "皇居ラン初心者歓迎！毎週水曜朝6時",
                body: "毎週水曜日の朝6時から皇居ランニングをしています。初心者大歓迎！ペースはゆっくりなので、気軽に参加してください。集合場所は竹橋駅前です。",
                category: .event,
                latitude: 35.6852,
                longitude: 139.7528,
                authorId: users[1].id,
                authorName: users[1].name,
                authorEmoji: users[1].avatarEmoji,
                createdAt: calendar.date(byAdding: .day, value: -2, to: Date())!,
                likeCount: 34,
                commentCount: 8,
                tags: ["ランニング", "皇居", "スポーツ"]
            ),
            Post(
                title: "日比谷公園でフリーマーケット開催！",
                body: "今週末、日比谷公園でフリーマーケットが開催されます。ハンドメイド雑貨、古着、レコードなど様々な出店があります。入場無料！",
                category: .event,
                latitude: 35.6735,
                longitude: 139.7560,
                authorId: users[1].id,
                authorName: users[1].name,
                authorEmoji: users[1].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -12, to: Date())!,
                likeCount: 42,
                commentCount: 6,
                tags: ["フリマ", "日比谷", "週末"]
            ),

            // 噂・口コミ
            Post(
                title: "銀座のあのパン屋さんが移転するらしい",
                body: "銀座4丁目にある老舗パン屋「パンの郷」が、来月末で移転するそうです。移転先は銀座6丁目の方だとか。常連の方はお早めに！",
                category: .rumor,
                latitude: 35.6717,
                longitude: 139.7653,
                authorId: users[3].id,
                authorName: users[3].name,
                authorEmoji: users[3].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -6, to: Date())!,
                likeCount: 15,
                commentCount: 7,
                tags: ["銀座", "パン", "移転"]
            ),
            Post(
                title: "新橋の居酒屋で芸能人目撃情報！",
                body: "昨日の夜、新橋のガード下の居酒屋でテレビでよく見る芸人さんを見かけました！ロケだったのかな？",
                category: .rumor,
                latitude: 35.6660,
                longitude: 139.7587,
                authorId: users[2].id,
                authorName: users[2].name,
                authorEmoji: users[2].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -15, to: Date())!,
                likeCount: 28,
                commentCount: 12,
                tags: ["新橋", "芸能人", "居酒屋"]
            ),

            // 落とし物
            Post(
                title: "東京駅構内で財布を拾いました",
                body: "東京駅丸の内中央改札付近で茶色の長財布を拾いました。駅の遺失物センターに届けてあります。お心当たりの方は駅係員にお問い合わせください。",
                category: .lostFound,
                latitude: 35.6812,
                longitude: 139.7671,
                authorId: users[0].id,
                authorName: users[0].name,
                authorEmoji: users[0].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -3, to: Date())!,
                likeCount: 8,
                commentCount: 1,
                tags: ["財布", "東京駅", "拾得物"]
            ),
            Post(
                title: "猫を探しています（キジトラ・オス）",
                body: "有楽町付近で飼い猫が逃げてしまいました。キジトラのオスで、首に青い首輪をしています。名前は「モチ」です。見かけた方はご連絡ください！",
                category: .lostFound,
                latitude: 35.6748,
                longitude: 139.7631,
                authorId: users[5].id,
                authorName: users[5].name,
                authorEmoji: users[5].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -1, to: Date())!,
                likeCount: 45,
                commentCount: 15,
                tags: ["猫", "迷子", "有楽町"]
            ),

            // 安全・防犯
            Post(
                title: "不審な訪問販売にご注意",
                body: "最近、この付近で消火器の訪問販売の詐欺が報告されています。「消防署の方から来ました」と偽って高額な消火器を売りつけてくるそうです。注意してください。",
                category: .safety,
                latitude: 35.6790,
                longitude: 139.7610,
                authorId: users[4].id,
                authorName: users[4].name,
                authorEmoji: users[4].avatarEmoji,
                createdAt: calendar.date(byAdding: .day, value: -1, to: Date())!,
                likeCount: 55,
                commentCount: 10,
                tags: ["詐欺", "訪問販売", "注意"]
            ),
            Post(
                title: "夜間の街灯が切れています",
                body: "日比谷通り沿い、帝国ホテル付近の街灯が3本ほど切れていて、夜間かなり暗くなっています。区役所に連絡済みですが、通行の際はお気をつけください。",
                category: .safety,
                latitude: 35.6730,
                longitude: 139.7580,
                authorId: users[0].id,
                authorName: users[0].name,
                authorEmoji: users[0].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -20, to: Date())!,
                likeCount: 22,
                commentCount: 3,
                isResolved: true,
                tags: ["街灯", "夜間", "日比谷"]
            ),

            // グルメ
            Post(
                title: "丸の内のランチ穴場スポット発見！",
                body: "丸ビル地下1階に新しくオープンしたイタリアンが絶品です！ランチセットが1,200円でパスタ＋サラダ＋ドリンク付き。まだあまり知られていないので空いてます。",
                category: .food,
                latitude: 35.6819,
                longitude: 139.7643,
                authorId: users[3].id,
                authorName: users[3].name,
                authorEmoji: users[3].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -4, to: Date())!,
                likeCount: 38,
                commentCount: 9,
                tags: ["ランチ", "イタリアン", "丸の内"]
            ),
            Post(
                title: "八重洲地下街のたい焼きが復活！",
                body: "八重洲地下街で閉店していたたい焼き屋さんが、場所を変えて復活していました！あんこがたっぷりで変わらない味です。嬉しい！",
                category: .food,
                latitude: 35.6798,
                longitude: 139.7695,
                authorId: users[3].id,
                authorName: users[3].name,
                authorEmoji: users[3].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -10, to: Date())!,
                likeCount: 56,
                commentCount: 11,
                tags: ["たい焼き", "八重洲", "スイーツ"]
            ),

            // 自然・散歩
            Post(
                title: "皇居東御苑の梅が見頃です",
                body: "皇居東御苑の梅林が見頃を迎えています。白梅と紅梅が美しく咲いていて、とても良い香りがします。入場無料なのでお散歩にぜひ。",
                category: .nature,
                latitude: 35.6860,
                longitude: 139.7580,
                authorId: users[2].id,
                authorName: users[2].name,
                authorEmoji: users[2].avatarEmoji,
                createdAt: calendar.date(byAdding: .hour, value: -7, to: Date())!,
                likeCount: 63,
                commentCount: 8,
                tags: ["梅", "皇居", "散歩", "花見"]
            ),
            Post(
                title: "日比谷公園で野鳥観察",
                body: "日比谷公園の池にカワセミが来ていました！この時期は毎日のように見られるそうです。朝早い時間帯がおすすめ。カメラを持っていきましょう。",
                category: .nature,
                latitude: 35.6740,
                longitude: 139.7550,
                authorId: users[2].id,
                authorName: users[2].name,
                authorEmoji: users[2].avatarEmoji,
                createdAt: calendar.date(byAdding: .day, value: -3, to: Date())!,
                likeCount: 40,
                commentCount: 6,
                tags: ["野鳥", "カワセミ", "日比谷公園"]
            ),
        ]
    }

    private static func sampleComments(posts: [Post], users: [CommunityUser]) -> [Comment] {
        let calendar = Calendar.current
        var comments: [Comment] = []

        // 工事情報へのコメント
        if let post = posts.first {
            comments.append(contentsOf: [
                Comment(postId: post.id, authorId: users[1].id, authorName: users[1].name, authorEmoji: users[1].avatarEmoji, body: "情報ありがとうございます！通勤ルート変更しないと。", createdAt: calendar.date(byAdding: .hour, value: -1, to: Date())!, likeCount: 3),
                Comment(postId: post.id, authorId: users[4].id, authorName: users[4].name, authorEmoji: users[4].avatarEmoji, body: "町内会でも回覧板で周知します。", createdAt: calendar.date(byAdding: .minute, value: -30, to: Date())!, likeCount: 5),
            ])
        }

        // 迷子猫へのコメント
        if posts.count > 9 {
            let catPost = posts[9]
            comments.append(contentsOf: [
                Comment(postId: catPost.id, authorId: users[1].id, authorName: users[1].name, authorEmoji: users[1].avatarEmoji, body: "有楽町マリオン付近で似た猫を見かけました！青い首輪してたと思います。", createdAt: calendar.date(byAdding: .minute, value: -45, to: Date())!, likeCount: 12),
                Comment(postId: catPost.id, authorId: users[4].id, authorName: users[4].name, authorEmoji: users[4].avatarEmoji, body: "町内の掲示板にも貼り紙を出しておきますね。早く見つかりますように。", createdAt: calendar.date(byAdding: .minute, value: -20, to: Date())!, likeCount: 8),
                Comment(postId: catPost.id, authorId: users[2].id, authorName: users[2].name, authorEmoji: users[2].avatarEmoji, body: "散歩のときに注意して探してみます！", createdAt: calendar.date(byAdding: .minute, value: -10, to: Date())!, likeCount: 4),
            ])
        }

        // ランチ情報へのコメント
        if posts.count > 12 {
            let lunchPost = posts[12]
            comments.append(contentsOf: [
                Comment(postId: lunchPost.id, authorId: users[0].id, authorName: users[0].name, authorEmoji: users[0].avatarEmoji, body: "行ってきました！カルボナーラが特においしかったです！", createdAt: calendar.date(byAdding: .hour, value: -2, to: Date())!, likeCount: 6),
                Comment(postId: lunchPost.id, authorId: users[5].id, authorName: users[5].name, authorEmoji: users[5].avatarEmoji, body: "子連れでも大丈夫ですか？ベビーカーで入れるかな。", createdAt: calendar.date(byAdding: .hour, value: -1, to: Date())!, likeCount: 2),
            ])
        }

        return comments
    }
}
