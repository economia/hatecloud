module.exports =
    useGzip: no
    redis:
        address: '127.0.0.1'
        port: 6379
    shouts:
        parties: <[ods]>
    antispam:
        timeout: 600_seconds
    admin:
        allowedIps: <[127.0.0.1 194.228.51.218 95.82.135.42]>
    wordCloud:
        width: 650_px
        height: 580_px
        maxSize: 90_px
        minSize: 5_px
        interval: 10_000_ms
        smallCloud:
            width: 295_px
            height: 195_px
            maxSize: 45_px
            minSize: 5_px
            colors:
                positive : \#a7f700
                negative : \#ff7600
                neutral  : \#ffd300
