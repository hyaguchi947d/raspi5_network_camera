# raspi5をネットワークカメラとして構築するためのスクリプト

- Author: Hiroaki Yaguchi, 947D-Tech.
- LICENSE: Unlicense

## 注意点

ローカルネットワーク内での動作を前提としています。
映像は容量が大きいので十分な帯域を確保してください。
インターネット越しの転送は無謀なので別の手段を考えてください。

## 準備するもの

- 送信側
  - Raspberry Pi 5 (2GBで十分動作します)
    - Raspberry Pi OS Liteにて動作確認しています。
  - Rasberry Pi Camera Module V3 (Wide)
    - 他のカメラの場合設定が異なる可能性があります。
- 受信側
  - Ubuntu 24.04で動作確認しています。

## セットアップ

### 送信側raspi5のセットアップ

OSはセットアップ済みであるものとします。

```
$ sudo apt install -y gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-tools gstreamer1.0-libcamera
```

動作確認済みのカメラ以外を使いたい場合、
formatを調査して該当箇所を書き換えれば多分動きます。
formatは以下のコマンドで調査できます。

```
$ sudo apt install gstreamer1.0-plugins-base-apps
$ gst-device-monitor-1.0 Video/Source
```

本リポジトリから`gst-sink.sh`をコピーしてください。

### 受信側PCのセットアップ

```
$ sudo apt install gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav v4l2loopback-utils
```

## 映像の送受信の実行

### 事前準備

受信側PCで以下の項目を確認してください。

- IPアドレスを確認して下さい。送信側で指定する必要があります。
- 通信に使うポートを決め、開放してください。送受信双方で指定する必要があります。
  - 複数台のraspi5を用意する場合はポートを台数分確保してください。

### 送信側raspi5から送信する

```
$ ./gst-sink.sh -h <受信側IP> -p <ポート>
```

複数台の場合は一台ごとにポートを変えてください。

### 受信側PCで受信する

#### 映像を表示する場合

```
$ ./gst-play.sh -p <ポート>
```

#### /dev/videoNに映像を流し込む場合

v4l2loopbackを用いることで、
PCに物理的に接続されたカメラと同じように扱うことができます。

サポートスクリプトを用意しましたが、
状況により大幅に異なると想定されるため
あくまで一例として捉えてください。
2台のraspiから送信された映像を/dev/video{10,11}に流し込む場合です。

```
$ sudo v4l2loopback_modprob.sh
```

スクリプトでやっていることは、
v4l2loopbackで新たなデバイス/dev/video{10,11}を作成します。
解除するにはv4l2loopbackを取り除いてください。

```
$ sudo modprobe -r v4l2loopback
```

v4l2loopbackによって/dev/videoNが存在している状態で、以下を実行してください。

```
$ ./gst-receive.sh -d <デバイス名> -p <ポート>
```

