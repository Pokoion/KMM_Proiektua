document.addEventListener('DOMContentLoaded', () => {
    const select = document.getElementById('video-select');
    const video = document.getElementById('my-video');
    
    if (!select || !video) return;

    const isABR = video.classList.contains('video-js');
    let player = null;

    if (isABR && typeof videojs !== 'undefined') {
        player = videojs('my-video');
        if (player.hlsQualitySelector) {
            player.hlsQualitySelector({ displayCurrentQuality: true });
        }
    }

    fetch('/api/videos')
        .then(res => res.json())
        .then(dirs => {
            console.log('Direktorioak:', dirs);
            const videos = dirs
                .filter(d => d.type === 'directory')
                .map(d => ({
                    name: d.name,
                    hls: `/streams/hls/${d.name}/master.m3u8`,
                    mp4: `/streams/mp4/${d.name}.mp4`
                }));

            if (videos.length === 0) {
                select.innerHTML = '<option>Ez dago bideorik</option>';
                return;
            }

            videos.forEach((v, i) => {
                const option = document.createElement('option');
                option.value = i;
                option.textContent = v.name;
                select.appendChild(option);
            });

            loadVideo(videos[0]);

            select.addEventListener('change', () => {
                const idx = parseInt(select.value);
                loadVideo(videos[idx]);
            });

            function loadVideo(v) {
                if (isABR && player) {
                    player.src({ src: v.hls, type: 'application/x-mpegURL' });
                } else {
                    video.src = v.mp4;
                    video.load();
                }
            }
        })
        .catch(err => {
            console.error('Errorea bideoak kargatzean:', err);
            select.innerHTML = '<option>Errorea kargatzean</option>';
        });
});