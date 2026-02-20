import Foundation

/// サンプル歴史データ
struct SampleHistoricalData {

    // MARK: - 京都の史跡

    static let kinkakuji = HistoricalSite(
        name: "金閣寺",
        nameReading: "きんかくじ",
        summary: "足利義満が建立した北山文化の象徴",
        description: """
        正式名称は鹿苑寺（ろくおんじ）。室町幕府三代将軍・足利義満が1397年に建立した山荘を、\
        義満の死後に禅寺としたものです。金箔で覆われた舎利殿は「金閣」と呼ばれ、北山文化を代表する建築物として\
        世界的に知られています。1950年に放火により焼失しましたが、1955年に再建されました。\
        庭園は特別史跡・特別名勝に指定され、1994年にはユネスコ世界遺産に登録されています。\
        鏡湖池に映る金閣の姿は、日本を代表する景観の一つです。
        """,
        era: .muromachi,
        category: .temple,
        yearBuilt: "1397年（応永4年）",
        latitude: 35.0394,
        longitude: 135.7292,
        address: "京都府京都市北区金閣寺町1",
        historicalFigures: ["足利義満", "夢窓疎石"],
        historicalEvents: ["北山文化の発展", "1950年放火事件", "1955年再建"],
        arDescription: "室町時代の金閣寺周辺には、義満の北山殿として広大な庭園と数々の殿舎が広がっていました。当時の金閣は現在よりもさらに豪華な装飾が施されていたとされます。",
        visitingHours: "9:00〜17:00",
        admissionFee: "大人400円"
    )

    static let fushimiInari = HistoricalSite(
        name: "伏見稲荷大社",
        nameReading: "ふしみいなりたいしゃ",
        summary: "千本鳥居で有名な稲荷神社の総本宮",
        description: """
        全国に約3万社あるといわれる稲荷神社の総本宮です。711年（和銅4年）に秦伊呂巨（はたのいろこ）が\
        稲荷山に神を祀ったのが始まりとされます。本殿は応仁の乱で焼失後、1499年に再建されたもので、\
        重要文化財に指定されています。千本鳥居と呼ばれる約1万基の朱塗りの鳥居が稲荷山の参道に連なる光景は\
        圧巻で、国内外から多くの参拝者が訪れます。商売繁盛・五穀豊穣の神として古くから信仰を集めています。
        """,
        era: .nara,
        category: .shrine,
        yearBuilt: "711年（和銅4年）",
        latitude: 34.9671,
        longitude: 135.7727,
        address: "京都府京都市伏見区深草藪之内町68",
        historicalFigures: ["秦伊呂巨", "秦氏"],
        historicalEvents: ["711年創建", "応仁の乱で焼失", "1499年本殿再建"],
        arDescription: "奈良時代、稲荷山は秦氏の本拠地として栄え、山全体が神域として崇められていました。当時は現在の千本鳥居はなく、自然の山道が続いていました。",
        visitingHours: "終日参拝可能",
        admissionFee: "無料"
    )

    static let kiyomizudera = HistoricalSite(
        name: "清水寺",
        nameReading: "きよみずでら",
        summary: "清水の舞台で知られる京都を代表する寺院",
        description: """
        778年（宝亀9年）に延鎮上人が開山し、坂上田村麻呂が仏殿を建立したと伝えられます。\
        本堂の「清水の舞台」は、崖の上に張り出した懸造り（かけづくり）の建築で、高さ約13メートル。\
        釘を一本も使わない伝統的な木造建築技法で造られています。境内からは京都市街を一望でき、\
        春の桜、秋の紅葉の名所としても名高い場所です。1994年にユネスコ世界遺産に登録されました。\
        「清水の舞台から飛び降りる」という慣用句の由来ともなっています。
        """,
        era: .nara,
        category: .temple,
        yearBuilt: "778年（宝亀9年）",
        latitude: 34.9949,
        longitude: 135.7850,
        address: "京都府京都市東山区清水1丁目294",
        historicalFigures: ["延鎮上人", "坂上田村麻呂"],
        historicalEvents: ["778年開山", "1633年本堂再建（徳川家光）", "世界遺産登録"],
        arDescription: "奈良時代末期、音羽山の中腹に小さな草庵として始まった清水寺。当時はまだ「清水の舞台」はなく、音羽の滝を中心とした修行の場でした。",
        visitingHours: "6:00〜18:00（季節により変動）",
        admissionFee: "大人400円"
    )

    static let nijocastle = HistoricalSite(
        name: "二条城",
        nameReading: "にじょうじょう",
        summary: "徳川幕府の栄華を伝える平城",
        description: """
        1603年（慶長8年）、徳川家康が天皇の住む京都御所の守護と将軍上洛時の宿泊所として築城しました。\
        二の丸御殿は国宝に指定されており、狩野派による障壁画約3,600面が残されています。\
        大広間は1867年（慶応3年）に15代将軍・徳川慶喜が大政奉還を表明した歴史的な場所です。\
        「鶯張り」の廊下は、歩くとキュッキュッと音が鳴り、侵入者を知らせる防犯装置として知られています。\
        1994年にユネスコ世界遺産に登録されました。
        """,
        era: .edo,
        category: .castle,
        yearBuilt: "1603年（慶長8年）",
        latitude: 35.0142,
        longitude: 135.7481,
        address: "京都府京都市中京区二条通堀川西入二条城町541",
        historicalFigures: ["徳川家康", "徳川慶喜", "徳川家光"],
        historicalEvents: ["1603年築城", "1626年後水尾天皇行幸", "1867年大政奉還"],
        arDescription: "江戸時代初期の二条城は、現在よりもさらに広大な敷地を持ち、天守閣がそびえ立っていました。1750年に落雷で天守を失い、現在は天守台のみが残ります。",
        visitingHours: "8:45〜16:00（閉城17:00）",
        admissionFee: "大人1,030円"
    )

    static let ginkakuji = HistoricalSite(
        name: "銀閣寺",
        nameReading: "ぎんかくじ",
        summary: "東山文化の精髄を伝えるわびさびの寺",
        description: """
        正式名称は慈照寺（じしょうじ）。室町幕府八代将軍・足利義政が1482年に造営を開始した山荘を、\
        義政の死後に禅寺としたものです。金閣寺の華やかさとは対照的に、銀箔は貼られておらず、\
        簡素な美しさが特徴です。観音殿（銀閣）は国宝に指定されており、東山文化を代表する建築です。\
        銀沙灘（ぎんしゃだん）と向月台と呼ばれる砂盛りの庭園は、月光を反射させるために造られたとされ、\
        日本の美意識「わびさび」を体現しています。
        """,
        era: .muromachi,
        category: .temple,
        yearBuilt: "1482年（文明14年）",
        latitude: 35.0270,
        longitude: 135.7983,
        address: "京都府京都市左京区銀閣寺町2",
        historicalFigures: ["足利義政"],
        historicalEvents: ["東山文化の発展", "応仁の乱後の造営"],
        arDescription: "室町時代後期、応仁の乱で荒廃した京都で、義政は東山に理想の山荘を造りました。当時は現在よりも多くの建物があり、文化サロンとして機能していました。",
        visitingHours: "8:30〜17:00",
        admissionFee: "大人500円"
    )

    // MARK: - 東京の史跡

    static let sensojiTemple = HistoricalSite(
        name: "浅草寺",
        nameReading: "せんそうじ",
        summary: "東京最古の寺院、雷門で有名",
        description: """
        628年（推古天皇36年）に創建されたと伝わる東京都内最古の寺院です。\
        隅田川で漁をしていた檜前浜成・竹成兄弟の網に聖観音像がかかり、それを祀ったのが始まりとされます。\
        雷門（正式名：風雷神門）の大提灯は浅草のシンボルとして親しまれています。\
        仲見世通りは日本最古の商店街の一つで、約250メートルの参道に約90の店舗が並びます。\
        江戸時代には徳川幕府の祈願所として栄え、門前町として賑わいました。
        """,
        era: .asuka,
        category: .temple,
        yearBuilt: "628年（推古天皇36年）",
        latitude: 35.7148,
        longitude: 139.7967,
        address: "東京都台東区浅草2-3-1",
        historicalFigures: ["檜前浜成", "檜前竹成", "土師中知"],
        historicalEvents: ["628年創建", "徳川家康祈願所指定", "1945年東京大空襲で焼失", "1958年再建"],
        arDescription: "飛鳥時代、この辺りは隅田川の河口近くの漁村でした。浅草寺の創建当時は小さな草庵で、周囲には田畑が広がっていました。",
        visitingHours: "6:00〜17:00（10月〜3月は6:30〜）",
        admissionFee: "無料"
    )

    static let imperialPalace = HistoricalSite(
        name: "江戸城跡（皇居）",
        nameReading: "えどじょうあと（こうきょ）",
        summary: "徳川将軍家の居城、現在の皇居",
        description: """
        1457年に太田道灌が築城し、1590年に徳川家康が入城して以降、徳川幕府の居城として約260年間にわたり\
        日本の政治の中心でした。本丸・二の丸・三の丸・西の丸・吹上など広大な敷地を持ち、\
        最盛期には日本最大の城郭でした。明治維新後は皇居となり、現在も天皇の住居として使用されています。\
        東御苑は一般公開されており、天守台や番所、石垣などの遺構を見学できます。\
        二重橋は皇居を象徴する景観として知られています。
        """,
        era: .edo,
        category: .castle,
        yearBuilt: "1457年（長禄元年）",
        latitude: 35.6852,
        longitude: 139.7528,
        address: "東京都千代田区千代田1-1",
        historicalFigures: ["太田道灌", "徳川家康", "徳川秀忠", "徳川家光"],
        historicalEvents: ["1457年太田道灌築城", "1590年家康入城", "1657年明暦の大火で天守焼失", "1868年東京遷都"],
        arDescription: "江戸時代の江戸城は、五層の天守閣がそびえ、広大な堀と石垣に囲まれた日本最大の城でした。城下町は100万人を超える世界最大級の都市でした。",
        visitingHours: "東御苑: 9:00〜16:30（季節により変動）",
        admissionFee: "無料（東御苑）"
    )

    static let zojoji = HistoricalSite(
        name: "増上寺",
        nameReading: "ぞうじょうじ",
        summary: "徳川将軍家の菩提寺",
        description: """
        1393年（明徳4年）に酉誉聖聡上人によって開山された浄土宗の大本山です。\
        徳川家康が江戸入府の際に菩提寺と定め、以降、徳川将軍15代のうち6人が葬られています。\
        三解脱門（三門）は1622年に建立された国の重要文化財で、東京都内最古の建造物の一つです。\
        東京タワーを背景にした三門の景観は、新旧の東京を象徴する風景として知られています。\
        境内には約200本の桜があり、春には花見の名所としても親しまれています。
        """,
        era: .muromachi,
        category: .temple,
        yearBuilt: "1393年（明徳4年）",
        latitude: 35.6586,
        longitude: 139.7454,
        address: "東京都港区芝公園4-7-35",
        historicalFigures: ["酉誉聖聡", "徳川家康", "徳川秀忠"],
        historicalEvents: ["1393年開山", "徳川家菩提寺指定", "1945年空襲で大部分焼失"],
        arDescription: "江戸時代の増上寺は、現在の芝公園一帯を含む広大な境内を持ち、120以上の堂宇が立ち並ぶ壮大な寺院でした。",
        visitingHours: "6:00〜17:30",
        admissionFee: "無料（徳川将軍家墓所は500円）"
    )

    // MARK: - 奈良の史跡

    static let todaiji = HistoricalSite(
        name: "東大寺",
        nameReading: "とうだいじ",
        summary: "奈良の大仏で知られる世界最大級の木造建築",
        description: """
        728年に聖武天皇が皇太子の菩提を弔うために建立した金鐘寺を起源とし、\
        741年の国分寺建立の詔を受けて総国分寺として整備されました。\
        大仏殿（金堂）に安置される盧舎那仏坐像（奈良の大仏）は、高さ約15メートルの世界最大級の金銅仏です。\
        現在の大仏殿は1709年に再建されたもので、幅57.5メートル、奥行50.5メートル、高さ46.8メートルと\
        世界最大級の木造建築物です。1998年にユネスコ世界遺産に登録されました。
        """,
        era: .nara,
        category: .temple,
        yearBuilt: "728年（神亀5年）",
        latitude: 34.6890,
        longitude: 135.8398,
        address: "奈良県奈良市雑司町406-1",
        historicalFigures: ["聖武天皇", "行基", "良弁"],
        historicalEvents: ["752年大仏開眼供養", "1180年平重衡の南都焼討", "1567年松永久秀の焼討", "1709年大仏殿再建"],
        arDescription: "奈良時代の東大寺は、現在よりもさらに広大で、七重塔が二基そびえ立ち、講堂や僧房が整然と並ぶ壮大な伽藍でした。大仏殿も現在の約1.5倍の幅がありました。",
        visitingHours: "7:30〜17:30（季節により変動）",
        admissionFee: "大人600円"
    )

    static let horyuji = HistoricalSite(
        name: "法隆寺",
        nameReading: "ほうりゅうじ",
        summary: "世界最古の木造建築群",
        description: """
        607年（推古天皇15年）に聖徳太子と推古天皇が創建したと伝えられる寺院です。\
        西院伽藍の金堂・五重塔は、現存する世界最古の木造建築として知られ、\
        約1400年の歴史を持ちます。五重塔は高さ約32.5メートルで、\
        地震国日本で千年以上も倒壊しなかった耐震構造の優秀さを示しています。\
        百済観音像や玉虫厨子など、飛鳥時代の貴重な文化財を多数所蔵しています。\
        1993年、日本で初めてユネスコ世界遺産に登録されました。
        """,
        era: .asuka,
        category: .temple,
        yearBuilt: "607年（推古天皇15年）",
        latitude: 34.6145,
        longitude: 135.7344,
        address: "奈良県生駒郡斑鳩町法隆寺山内1-1",
        historicalFigures: ["聖徳太子", "推古天皇"],
        historicalEvents: ["607年創建", "670年焼失（日本書紀）", "7世紀末〜8世紀初頭再建", "1993年世界遺産登録"],
        arDescription: "飛鳥時代、法隆寺周辺は斑鳩の里として知られ、聖徳太子の斑鳩宮がありました。当時の寺院は朱塗りの柱と白壁が鮮やかな、大陸風の壮麗な建築でした。",
        visitingHours: "8:00〜17:00（11月〜2月は16:30まで）",
        admissionFee: "大人1,500円"
    )

    // MARK: - 大阪の史跡

    static let osakacastle = HistoricalSite(
        name: "大阪城",
        nameReading: "おおさかじょう",
        summary: "豊臣秀吉が築いた天下統一の象徴",
        description: """
        1583年（天正11年）に豊臣秀吉が石山本願寺跡地に築城を開始し、1585年に完成しました。\
        秀吉時代の大坂城は金箔瓦で飾られた絢爛豪華な城でした。1615年の大坂夏の陣で落城後、\
        徳川幕府により再建されましたが、1665年に落雷で天守を焼失。現在の天守閣は1931年に\
        市民の寄付により鉄筋コンクリートで再建されたもので、内部は歴史博物館となっています。\
        石垣の壮大さは日本有数で、最大の「蛸石」は約130トンもの重さがあります。
        """,
        era: .azuchiMomoyama,
        category: .castle,
        yearBuilt: "1583年（天正11年）",
        latitude: 34.6873,
        longitude: 135.5262,
        address: "大阪府大阪市中央区大阪城1-1",
        historicalFigures: ["豊臣秀吉", "豊臣秀頼", "徳川家康"],
        historicalEvents: ["1583年築城開始", "1615年大坂夏の陣", "1931年天守閣再建"],
        arDescription: "安土桃山時代の大坂城は、金箔瓦が輝く五層の天守閣がそびえ、城下には活気ある商人町が広がっていました。秀吉の天下統一の象徴として、その壮大さは全国に知られていました。",
        visitingHours: "9:00〜17:00（入館は16:30まで）",
        admissionFee: "大人600円"
    )

    static let shitennoji = HistoricalSite(
        name: "四天王寺",
        nameReading: "してんのうじ",
        summary: "聖徳太子建立の日本最古の官寺",
        description: """
        593年（推古天皇元年）に聖徳太子が建立した日本最古の本格的な仏教寺院です。\
        物部守屋との戦いに際し、四天王に戦勝を祈願し、勝利後に建立したと伝えられます。\
        伽藍配置は「四天王寺式」と呼ばれ、中門・塔・金堂・講堂が一直線に並ぶ形式で、\
        日本最古の伽藍配置様式として知られています。度重なる戦災や災害で焼失を繰り返しましたが、\
        その都度、創建時の様式に忠実に再建されてきました。
        """,
        era: .asuka,
        category: .temple,
        yearBuilt: "593年（推古天皇元年）",
        latitude: 34.6533,
        longitude: 135.5164,
        address: "大阪府大阪市天王寺区四天王寺1-11-18",
        historicalFigures: ["聖徳太子", "物部守屋"],
        historicalEvents: ["593年建立", "物部氏との戦い", "度重なる再建"],
        arDescription: "飛鳥時代、四天王寺は海に近い高台に建ち、大陸からの使節を迎える日本の威信を示す寺院でした。朱と白の鮮やかな建物が立ち並び、仏教文化の中心地でした。",
        visitingHours: "8:30〜16:30",
        admissionFee: "中心伽藍 大人300円"
    )

    // MARK: - 鎌倉の史跡

    static let tsurugaokaHachimangu = HistoricalSite(
        name: "鶴岡八幡宮",
        nameReading: "つるがおかはちまんぐう",
        summary: "鎌倉幕府の守護神社",
        description: """
        1063年（康平6年）に源頼義が京都の石清水八幡宮を勧請したのが始まりです。\
        1180年に源頼朝が現在地に遷し、鎌倉幕府の宗社として整備しました。\
        若宮大路は鶴岡八幡宮への参道として造られた鎌倉のメインストリートで、\
        段葛（だんかずら）と呼ばれる一段高い歩道が特徴です。\
        本宮（上宮）は国の重要文化財に指定されています。\
        源実朝暗殺事件の舞台となった大銀杏は2010年に倒伏しましたが、再生が試みられています。
        """,
        era: .kamakura,
        category: .shrine,
        yearBuilt: "1063年（康平6年）",
        latitude: 35.3256,
        longitude: 139.5565,
        address: "神奈川県鎌倉市雪ノ下2-1-31",
        historicalFigures: ["源頼義", "源頼朝", "源実朝", "公暁"],
        historicalEvents: ["1063年創建", "1180年鎌倉遷座", "1219年源実朝暗殺"],
        arDescription: "鎌倉時代、鶴岡八幡宮は武家の都・鎌倉の中心として、壮大な社殿と広大な境内を持っていました。若宮大路は海まで真っすぐに伸び、武士たちが行き交っていました。",
        visitingHours: "6:00〜20:30",
        admissionFee: "無料（宝物殿は200円）"
    )

    static let daibutsu = HistoricalSite(
        name: "鎌倉大仏（高徳院）",
        nameReading: "かまくらだいぶつ（こうとくいん）",
        summary: "露座の大仏として知られる国宝の阿弥陀如来像",
        description: """
        1252年（建長4年）に鋳造が開始された青銅製の阿弥陀如来坐像です。\
        像高約11.3メートル、重量約121トンの巨大な仏像で、国宝に指定されています。\
        当初は大仏殿の中に安置されていましたが、1498年の明応地震による津波で大仏殿が流失し、\
        以来500年以上にわたって露座（野外）のまま鎮座しています。\
        胎内に入ることができ、鋳造技術の高さを間近で観察することができます。
        """,
        era: .kamakura,
        category: .monument,
        yearBuilt: "1252年（建長4年）",
        latitude: 35.3167,
        longitude: 139.5356,
        address: "神奈川県鎌倉市長谷4-2-28",
        historicalFigures: [],
        historicalEvents: ["1252年鋳造開始", "1498年津波で大仏殿流失"],
        arDescription: "鎌倉時代には、大仏は壮大な大仏殿の中に安置されていました。殿堂は高さ約40メートルの巨大な建物で、鎌倉の街からもその姿が見えたと言われています。",
        visitingHours: "8:00〜17:30（10月〜3月は17:00まで）",
        admissionFee: "大人300円（胎内拝観50円）"
    )

    // MARK: - 姫路の史跡

    static let himejicastle = HistoricalSite(
        name: "姫路城",
        nameReading: "ひめじじょう",
        summary: "白鷺城の愛称で知られる国宝・世界遺産の名城",
        description: """
        1346年に赤松貞範が築城したのが始まりで、1601年から1609年にかけて池田輝政が大改修を行い、\
        現在の姿になりました。白漆喰の美しい外観から「白鷺城」とも呼ばれます。\
        大天守は五重六階地下一階の構造で、高さ約31.5メートル。日本に現存する12の天守の一つであり、\
        その中でも最大規模を誇ります。1993年に日本初のユネスコ世界遺産に登録されました。\
        2015年に「平成の大修理」が完了し、築城当時の白さが蘇りました。
        """,
        era: .edo,
        category: .castle,
        yearBuilt: "1346年（正平元年）/ 1609年大改修",
        latitude: 34.8394,
        longitude: 134.6939,
        address: "兵庫県姫路市本町68",
        historicalFigures: ["赤松貞範", "池田輝政", "黒田官兵衛"],
        historicalEvents: ["1346年築城", "1609年大改修完了", "1993年世界遺産登録", "2015年平成の大修理完了"],
        arDescription: "江戸時代初期の姫路城は、現在と同様の白く美しい姿で、城下町には侍屋敷や商人町が広がっていました。当時は更に多くの櫓や門が存在し、難攻不落の要塞でした。",
        visitingHours: "9:00〜16:00（閉城17:00）",
        admissionFee: "大人1,000円"
    )

    // MARK: - 広島の史跡

    static let itsukushima = HistoricalSite(
        name: "厳島神社",
        nameReading: "いつくしまじんじゃ",
        summary: "海上に浮かぶ朱の大鳥居と社殿",
        description: """
        593年に佐伯鞍職が創建したと伝えられ、1168年に平清盛が現在の海上社殿の形に造営しました。\
        満潮時には海に浮かんでいるように見える社殿と大鳥居は、日本三景の一つとして\
        古くから人々を魅了してきました。大鳥居は高さ約16.6メートルで、自重だけで立っています。\
        本殿・拝殿・回廊など6棟が国宝、14棟が重要文化財に指定されています。\
        1996年にユネスコ世界遺産に登録されました。
        """,
        era: .heian,
        category: .shrine,
        yearBuilt: "593年創建 / 1168年現在の形に造営",
        latitude: 34.2961,
        longitude: 132.3198,
        address: "広島県廿日市市宮島町1-1",
        historicalFigures: ["佐伯鞍職", "平清盛"],
        historicalEvents: ["593年創建", "1168年平清盛による造営", "1996年世界遺産登録"],
        arDescription: "平安時代末期、平清盛の時代には厳島神社は平家の氏神として崇められ、清盛は自ら参詣を繰り返しました。当時の社殿は現在よりもさらに壮麗で、平家の栄華を反映していました。",
        visitingHours: "6:30〜18:00（季節により変動）",
        admissionFee: "大人300円"
    )

    // MARK: - 全データ

    static let allSites: [HistoricalSite] = [
        kinkakuji,
        fushimiInari,
        kiyomizudera,
        nijocastle,
        ginkakuji,
        sensojiTemple,
        imperialPalace,
        zojoji,
        todaiji,
        horyuji,
        osakacastle,
        shitennoji,
        tsurugaokaHachimangu,
        daibutsu,
        himejicastle,
        itsukushima,
    ]

    // MARK: - サンプルルート

    static let kyotoRoute = WalkingRoute(
        name: "京都黄金ルート",
        description: "金閣寺から銀閣寺まで、京都の名刹を巡る王道コース",
        siteIDs: [kinkakuji.id, nijocastle.id, ginkakuji.id],
        estimatedDurationMinutes: 180,
        distanceKilometers: 8.5,
        difficulty: .moderate
    )

    static let kyotoTempleRoute = WalkingRoute(
        name: "京都東山散策",
        description: "清水寺から伏見稲荷まで、東山エリアの寺社を巡るコース",
        siteIDs: [kiyomizudera.id, fushimiInari.id],
        estimatedDurationMinutes: 150,
        distanceKilometers: 6.0,
        difficulty: .moderate
    )

    static let tokyoRoute = WalkingRoute(
        name: "東京歴史探訪",
        description: "皇居から浅草まで、東京の歴史スポットを巡るコース",
        siteIDs: [imperialPalace.id, zojoji.id, sensojiTemple.id],
        estimatedDurationMinutes: 240,
        distanceKilometers: 12.0,
        difficulty: .hard
    )

    static let kamakuraRoute = WalkingRoute(
        name: "鎌倉古都散策",
        description: "鎌倉大仏から鶴岡八幡宮まで、武家の都を歩くコース",
        siteIDs: [daibutsu.id, tsurugaokaHachimangu.id],
        estimatedDurationMinutes: 120,
        distanceKilometers: 3.5,
        difficulty: .easy
    )

    static let naraRoute = WalkingRoute(
        name: "奈良古寺巡礼",
        description: "東大寺から法隆寺まで、奈良時代の古寺を訪ねるコース",
        siteIDs: [todaiji.id, horyuji.id],
        estimatedDurationMinutes: 300,
        distanceKilometers: 15.0,
        difficulty: .hard
    )

    static let allRoutes: [WalkingRoute] = [
        kyotoRoute,
        kyotoTempleRoute,
        tokyoRoute,
        kamakuraRoute,
        naraRoute,
    ]
}
