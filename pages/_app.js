import "../styles/globals.css";
import Link from "next/link";

function MyApp({ Component, pageProps }) {
  return (
    <div>
      <div className="border-b p-6">
        <p className="text-4xl font-bold">Splash Marketplace</p>
        <div className="flex mt-4">
          <Link href="/">
            <a className="text-blue-500 hover:text-blue-700 mr-6">Home</a>
          </Link>
          <Link href="/create-item">
            <a className="text-blue-500 hover:text-blue-700 mr-6">
              Sell Digital Asset
            </a>
          </Link>
          <Link href="/my-assets">
            <a className="text-blue-500 hover:text-blue-700 mr-6">
              My Digital Assets
            </a>
          </Link>
          <Link href="/creator-dashboard">
            <a className="text-blue-500 hover:text-blue-700 mr-6">
              Creator Dashboard
            </a>
          </Link>
        </div>
      </div>
      <Component {...pageProps} />
    </div>
  );
}

export default MyApp;
