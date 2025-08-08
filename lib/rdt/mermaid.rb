require "base64"
module Rdt
  class Mermaid
    class << self
      def markdown_for(dag)
        mermaid = "flowchart LR\n"
        dag.each do |model, dependencies|
          mermaid += "#{model}\n"
          dependencies.each do |dependency|
            mermaid += "#{dependency} --> #{model}\n"
          end
        end
        mermaid
      end

      def generate_file(chart)
        html = <<~HTML
          <!DOCTYPE html>
            <html lang="en">
              <body>
                <style>svg { max-width: none; width: 2000px; }</style>
                <pre class="mermaid">
                #{chart}
                </pre>
                <script type="module">
                  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
                </script>
              </body>
            </html>
        HTML

        begin
          File.write("dependencies.html", html)
        rescue Errno::EACCES => e
          puts "Failed to write to file: #{e.message}"
        end
      end
    end
  end
end
