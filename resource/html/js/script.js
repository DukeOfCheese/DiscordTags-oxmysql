$(document).ready(function() {
    function formatMessage(message) {
        if (!message) return "";
        function colorizeMessage(msg) {
          return msg
            .replace(/\^([0-9])/g, (match, color) => `</span><span class="color-${color}">`) 
            .replace(/\^#([0-9A-F]{3,6})/gi, (match, color) => `</span><span class="color" style="color: #${color}">`) 
            .replace(/~([a-z])~/g, (match, color) => `</span><span class="gameColor-${color}">`);
        }
      
        const transformedMessage = `<span>${colorizeMessage(message)}</span>`; 
      
        return transformedMessage;
      }

    window.addEventListener('message', function(event) {
        if (event.data.type === 'config') {
            const $hudElement = $('.headtag-prefix');
            
            if (!event.data.enabled) {
                $hudElement.hide();
                return;
            }
            
            $hudElement
                .show()
                .css({
                    'right': event.data.position.x + 'px',
                    'top': event.data.position.y + 'px'
                });
        }

        if (event.data.type === 'updateHeadtag') {
            const $headtagText = $('.headtag-text');
            let headtag = event.data.headtag;
            
            if (headtag === 'N/A') {
                $headtagText.text('N/A');
            } else {
                headtag = formatMessage(headtag);
                $headtagText.html(headtag || '');
            }
        }

        if (event.data.type === 'updateGangtag') {
            const $gangtagText = $('.gangtag-text');
            let gangtag = event.data.gangtag;

            if (gangtag === 'N/A') {
                $gangtagText.text('N/A');
            } else {
                gangtag = formatMessage(gangtag);
                $gangtagText.html(gangtag || '');
            }
        }
    });
});
