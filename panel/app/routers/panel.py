"""Panel API endpoints"""
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse, Response
from pathlib import Path
from app.config import settings

router = APIRouter()


@router.get("/ca")
async def get_ca_cert(download: bool = False):
    """Get CA certificate for node enrollment"""
    from app.hysteria2_server import Hysteria2Server
    import os
    
    # Resolve certificate path (handle relative paths)
    cert_path = Path(settings.hysteria2_cert_path)
    if not cert_path.is_absolute():
        # If relative, resolve from app directory
        cert_path = Path(__file__).parent.parent.parent / cert_path
    
    # Ensure parent directory exists
    cert_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Generate certificate if it doesn't exist or is empty
    if not cert_path.exists() or (cert_path.exists() and cert_path.stat().st_size == 0):
        print(f"CA certificate missing or empty at {cert_path}, generating...")
        h2_server = Hysteria2Server()
        await h2_server._generate_certs()
        # Re-resolve path after generation
        cert_path = Path(settings.hysteria2_cert_path)
        if not cert_path.is_absolute():
            cert_path = Path(__file__).parent.parent.parent / cert_path
        print(f"Certificate generated at {cert_path}")
    
    if not cert_path.exists():
        raise HTTPException(status_code=500, detail=f"Failed to generate CA certificate at {cert_path}")
    
    # Check if file is empty
    try:
        cert_content = cert_path.read_text()
        if not cert_content or not cert_content.strip():
            raise HTTPException(status_code=500, detail="CA certificate is empty")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read certificate: {str(e)}")
    
    # If download parameter is true, return as file download
    if download:
        return FileResponse(
            cert_path,
            media_type="application/x-pem-file",
            filename="ca.crt",
            headers={"Content-Disposition": "attachment; filename=ca.crt"}
        )
    
    # Otherwise return as text (for display/copy in UI)
    return Response(content=cert_content, media_type="text/plain")


@router.get("/health")
async def health():
    """Health check"""
    return {"status": "ok"}

