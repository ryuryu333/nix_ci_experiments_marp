# nix_ci_experiments_marp
Nix の devShells を利用した GitHub Actions の CI のサンプル。

marp を利用して markdown から スライド pdf を静的生成します。

以下に示す通り、ローカルと CI で同じコマンドを実行してスライド生成できます。

```
# ローカル
nix develop -c task marp -- slides/test
# or
# nix develop 後
task marp -- slides/test

# CI
nix develop -c task marp -- slides/test
# or
nix develop .#ci -c task marp -- slides/test
```


## 注意
### OS について
WSL Ubuntu、Macbook（x86_64-linux、aarch64-darwin）前提の環境です。
Ubuntu では問題なく動くはずです。

Mac は OS 固有の仕様上、以下の様な問題があるのでご留意ください。

- pdf 生成に必要な chrome が nixpkgs では導入できない
  - -> 別途導入が必要
- chrome で利用するフォントの制御が fontconfig ではない 
  - -> flake.nix で指定したフォントを利用できない（設定が大変なので未実施）

### act について
GitHub Actions のローカル動作確認のために、[nektos/act](https://github.com/nektos/act) を利用しています。
flake.nix だけでは管理・再現できない要素なので、試すのは面倒だと思います。

試したい人は以下をご参考ください。

act は Docker を利用します。
Docker を動かすためのコンテナランタイムとして colima を利用しています。

flake.nix の記述だけだと動作しませず、以下の操作が必要です。

#### WSL Ubuntu のみの準備
sudo 権限が必要な設定があります。

```
sudo apt install uidmap
sudo usermod -aG kvm $USER
```

#### Ubuntu / Mac 共通

```
colima start
gh auth login
```

#### act の task
--container-daemon-socket で渡すパスを適宜修正してください。
