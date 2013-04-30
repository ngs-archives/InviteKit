#InviteKit導入手順

##ソース取得

- git clone
- git submodule update


##諸々設定

- (InviteDemoAppConfigurator.sample.mを複製してInviteDemoAppConfigurator.mにリネーム)
- Facebook Developersでアプリ生成
  - Info.plistに設定してあるBundle IDを、Facebook Developersにも設定
- AppSociallyでアプリ生成
- InviteDemoAppConfigurator.m に **Facebook App ID** と **AppSocially API Key** を設定

これでDemoAppが動作するようになる。


##InviteKitのデモアプリでAppSociallyを試してみる

###インストールしてみる

AppSocially の Dashboard の "Settings" タブで、**Users** が増える


###招待してみる

AppSocially の Dashboard の "**Invitations**" タブで、レコードが追加される


###招待された側のアカウントで、メッセージを見てみる

AppSocially の Dashboard の "Invitations" タブのレコードの **Referrals** が増える


###招待された側のアカウントで、メッセージ内のリンクをクリックしてみる

AppSocially の Dashboard の "Invitations" タブのレコードの **Visitors** が増える


###招待された側のアカウントで、メッセージ内のリンクをクリックして遷移された先のリンクをクリックしてみる

AppSocially の Dashboard の "Invitations" タブのレコードの **Acquisitions** が増える
